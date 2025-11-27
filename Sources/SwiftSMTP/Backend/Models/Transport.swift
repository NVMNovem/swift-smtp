//
//  SMTPTransport.swift
//  SwiftSMTP
//
//  Created by Damian Van de Kauter on 27/11/2025.
//

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
}
