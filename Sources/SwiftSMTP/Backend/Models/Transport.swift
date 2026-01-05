//
//  SMTPTransport.swift
//  SwiftSMTP
//
//  Created by Damian Van de Kauter on 27/11/2025.
//

import Foundation

import NIO
import NIOSSL
import NIOExtras

internal actor Transport {
    
    private let host: String
    private let port: Int
    private let group: MultiThreadedEventLoopGroup
    private var channel: Channel?
    private var lineBuffer: [String]
    private var lineContinuations: [(String) -> Void]
    
    internal init(
        host: String,
        port: Int,
        channel: Channel? = nil,
        lineBuffer: [String] = [],
        lineContinuations: [(String) -> Void] = []
    ) {
        self.host = host
        self.port = port
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.channel = channel
        self.lineBuffer = lineBuffer
        self.lineContinuations = lineContinuations
    }
    
    internal func connect() async throws {
        let bootstrap = ClientBootstrap(group: group)
            .channelInitializer { channel in
                channel.pipeline.addHandler(ByteToMessageHandler(LineBasedFrameDecoder()))
                    .flatMap { _ in
                        // Use Task to hop into actor context when a line is received.
                        channel.pipeline.addHandler(LineReaderHandler { [weak self] line in
                            Task { [weak self] in
                                await self?.handleLine(line)
                            }
                        })
                    }
            }
        
        self.channel = try await bootstrap.connect(host: host, port: port).get()
        _ = try await readLine()
    }
    
    internal func close() {
        try? channel?.close().wait()
        try? group.syncShutdownGracefully()
    }
}

internal extension Transport {
    
    func startTLS() async throws {
        guard let channel else { throw Error.invalidChannel }
        
        let tlsConfiguration = TLSConfiguration.makeClientConfiguration()
        let tlsContext = try NIOSSLContext(configuration: tlsConfiguration)
        let sslHandler = try NIOSSLClientHandler(context: tlsContext, serverHostname: host)
        
        try await channel.pipeline.addHandler(sslHandler, position: .first).get()
    }
}

extension Transport {
    
    private func handleLine(_ line: String) {
        if let continuation = lineContinuations.first {
            lineContinuations.removeFirst()
            continuation(line)
        } else {
            lineBuffer.append(line)
        }
    }
    
    func sendLine(_ line: String) {
        guard let channel else { return }
        
        let data = line + "\r\n"
        var buffer = channel.allocator.buffer(capacity: data.utf8.count)
        buffer.writeString(data)
        channel.writeAndFlush(buffer, promise: nil)
    }
    
    func sendRaw(_ string: String) {
        guard let channel else { return }

        var buffer = channel.allocator.buffer(capacity: string.utf8.count)
        buffer.writeString(string)
        channel.writeAndFlush(buffer, promise: nil)
    }
    
    func readLine() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            if !lineBuffer.isEmpty {
                let line = lineBuffer.removeFirst()
                continuation.resume(returning: line)
            } else {
                lineContinuations.append { line in
                    continuation.resume(returning: line)
                }
            }
        }
    }
    
    func readResponse() async throws -> (code: Int, lines: [String]) {
        var lines: [String] = []
        let first = try await readLine()
        lines.append(first)
        guard first.count >= 3, let code = Int(first.prefix(3)) else {
            throw Error.invalidResponse
        }
        if first.count > 3 && first[first.index(first.startIndex, offsetBy: 3)] == "-" {
            while true {
                let line = try await readLine()
                lines.append(line)
                if line.hasPrefix("\(code) ") { break }
            }
        }
        return (code, lines)
    }
    
    func authenticateLogin(username: String, password: String) async throws {
        sendLine("AUTH LOGIN")
        let r1 = try await readResponse()
        guard r1.code == 334 else { throw Error.authenticationFailed }
        
        sendLine(Data(username.utf8).base64EncodedString())
        let r2 = try await readResponse()
        guard r2.code == 334 else { throw Error.authenticationFailed }
        
        sendLine(Data(password.utf8).base64EncodedString())
        let r3 = try await readResponse()
        guard r3.code == 235 else { throw Error.authenticationFailed }
    }
    
    func authenticatePlain(_ credentials: SMTPCredentials) async throws {
        let authString = "\u{00}\(credentials.username)\u{00}\(credentials.password)"
        let payload = Data(authString.utf8).base64EncodedString()
        
        sendLine("AUTH PLAIN \(payload)")
        let response = try await readResponse()
        guard response.code == 235 else {
            throw Error.authenticationFailed
        }
    }
}
