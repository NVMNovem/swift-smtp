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
    private let connectTimeout: Duration
    private let responseTimeout: Duration
    private let group: MultiThreadedEventLoopGroup
    private var channel: Channel?
    private var eventsTask: Task<Void, Never>?
    private var lineBuffer: [String]
    private var lineWaiters: [LineWaiter]

    /// Set once the connection is lost; every later read fails with this error instead of waiting forever.
    private var closedError: Error?

    internal init(
        host: String,
        port: Int,
        connectTimeout: Duration,
        responseTimeout: Duration
    ) {
        self.host = host
        self.port = port
        self.connectTimeout = connectTimeout
        self.responseTimeout = responseTimeout
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.channel = nil
        self.eventsTask = nil
        self.lineBuffer = []
        self.lineWaiters = []
        self.closedError = nil
    }

    internal func connect() async throws {
        let (events, eventsContinuation) = AsyncStream<LineReaderHandler.Event>.makeStream()
        let bootstrap = ClientBootstrap(group: group)
            .connectTimeout(.nanoseconds(connectTimeout.nanoseconds))
            .channelInitializer { channel in
                channel.pipeline.addHandler(ByteToMessageHandler(LineBasedFrameDecoder()))
                    .flatMap { _ in
                        channel.pipeline.addHandler(LineReaderHandler(events: eventsContinuation))
                    }
            }

        lineBuffer = []
        closedError = nil

        // A single consumer handles the events in the order NIO produced them.
        eventsTask = Task { [weak self] in
            for await event in events {
                await self?.handle(event)
            }
        }

        do {
            self.channel = try await bootstrap.connect(host: host, port: port).get()
        } catch {
            eventsContinuation.finish()
            throw error
        }
        _ = try await readLine()
    }

    internal func close() async {
        try? await channel?.close().get()
        channel = nil
        fail(with: .connectionClosed(nil))
        eventsTask?.cancel()
        eventsTask = nil
        try? await group.shutdownGracefully()
    }

    /// Throws when the connection has been lost, so callers can stop instead of sending into a dead session.
    internal func ensureOpen() throws {
        if let closedError { throw closedError }
        guard channel != nil else { throw Error.invalidChannel }
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

    private struct LineWaiter {
        let id: UUID
        let continuation: CheckedContinuation<String, Swift.Error>
        let timeoutTask: Task<Void, Never>
    }

    private func handle(_ event: LineReaderHandler.Event) {
        switch event {
        case .line(let line):
            if !lineWaiters.isEmpty {
                let waiter = lineWaiters.removeFirst()
                waiter.timeoutTask.cancel()
                waiter.continuation.resume(returning: line)
            } else {
                lineBuffer.append(line)
            }
        case .failed(let error):
            fail(with: .connectionClosed(error))
        case .closed:
            fail(with: .connectionClosed(nil))
        }
    }

    /// Marks the connection as lost and fails every pending read.
    private func fail(with error: Error) {
        // Keep the first error; it's the most specific one (e.g. a TLS failure before the close).
        if closedError == nil {
            closedError = error
        }

        let waiters = lineWaiters
        lineWaiters.removeAll()
        for waiter in waiters {
            waiter.timeoutTask.cancel()
            waiter.continuation.resume(throwing: closedError ?? error)
        }
    }

    private func timeOut(_ id: UUID) {
        guard lineWaiters.contains(where: { $0.id == id }) else { return }

        // A missing reply leaves the session out of sync, so give up on the whole connection.
        fail(with: .timeout(responseTimeout))
        channel?.close(promise: nil)
    }

    func sendLine(_ line: String) {
        guard let channel else { return }

        let data = line + "\r\n"
        var buffer = channel.allocator.buffer(capacity: data.utf8.count)
        buffer.writeString(data)
        channel.writeAndFlush(buffer, promise: nil)
    }

    func sendRaw(_ data: Data) {
        guard let channel else { return }

        var buffer = channel.allocator.buffer(capacity: data.count)
        buffer.writeBytes(data)
        channel.writeAndFlush(buffer, promise: nil)
    }

    func readLine() async throws -> String {
        if !lineBuffer.isEmpty {
            return lineBuffer.removeFirst()
        }
        if let closedError {
            throw closedError
        }

        let id = UUID()
        let timeout = responseTimeout
        return try await withCheckedThrowingContinuation { continuation in
            let timeoutTask = Task { [weak self] in
                do {
                    try await Task.sleep(for: timeout)
                } catch {
                    return
                }
                await self?.timeOut(id)
            }
            lineWaiters.append(LineWaiter(id: id, continuation: continuation, timeoutTask: timeoutTask))
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
