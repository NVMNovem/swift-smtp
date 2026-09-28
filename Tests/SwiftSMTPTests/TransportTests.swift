//
//  TransportTests.swift
//  SwiftSMTP
//
//  Created by Damian Van de Kauter on 28/09/2026.
//

import Testing
import Foundation
import NIO
import NIOExtras

@testable import SwiftSMTP

@Test
func sendThrowsWhenServerNeverReplies() async throws {
    let server = try await FakeSMTPServer.start { _, _ in }
    defer { server.stop() }

    let client = Client(host: "127.0.0.1", port: server.port, responseTimeout: .milliseconds(500))
    let mail = Mail(from: Mail.Contact(email: "from@example.com"), to: "to@example.com", subject: "Test", text: "Test")

    let start = ContinuousClock.now
    await #expect(throws: (any Error).self) {
        try await client.send(mail)
    }
    #expect(ContinuousClock.now - start < .seconds(5))
}

@Test
func sendThrowsWhenServerDropsConnectionMidSession() async throws {
    let server = try await FakeSMTPServer.start { context, line in
        if line == nil {
            context.writeLine("220 fake ESMTP")
        } else {
            // Drop the connection instead of answering EHLO.
            context.close(promise: nil)
        }
    }
    defer { server.stop() }

    // A long response timeout proves the failure comes from the close, not from the timeout.
    let client = Client(host: "127.0.0.1", port: server.port, responseTimeout: .seconds(60))
    let mail = Mail(from: Mail.Contact(email: "from@example.com"), to: "to@example.com", subject: "Test", text: "Test")

    let start = ContinuousClock.now
    await #expect(throws: (any Error).self) {
        try await client.send(mail)
    }
    #expect(ContinuousClock.now - start < .seconds(5))
}

@Test
func readResponseKeepsMultilineRepliesInOrder() async throws {
    let lineCount = 200
    let server = try await FakeSMTPServer.start { context, line in
        if line == nil {
            context.writeLine("220 fake ESMTP")
        } else {
            for index in 0..<lineCount - 1 {
                context.writeLine("250-line \(index)")
            }
            context.writeLine("250 line \(lineCount - 1)")
        }
    }
    defer { server.stop() }

    let transport = Transport(host: "127.0.0.1", port: server.port, connectTimeout: .seconds(5), responseTimeout: .seconds(5))
    try await transport.connect()
    await transport.sendLine("EHLO localhost")
    let response = try await transport.readResponse()
    await transport.close()

    #expect(response.code == 250)
    #expect(response.lines.count == lineCount)
    #expect(response.lines.last == "250 line \(lineCount - 1)")
    for (index, line) in response.lines.dropLast().enumerated() {
        #expect(line == "250-line \(index)")
    }
}

// MARK: - Fake server

/// A local TCP server that answers SMTP lines through a script.
/// The script is called with `nil` when a client connects, and with every line the client sends.
private final class FakeSMTPServer: Sendable {

    typealias Script = @Sendable (ChannelHandlerContext, String?) -> Void

    private let group: MultiThreadedEventLoopGroup
    private let channel: Channel

    var port: Int { channel.localAddress?.port ?? 0 }

    private init(group: MultiThreadedEventLoopGroup, channel: Channel) {
        self.group = group
        self.channel = channel
    }

    static func start(script: @escaping Script) async throws -> FakeSMTPServer {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let channel = try await ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelInitializer { channel in
                channel.pipeline.addHandler(ByteToMessageHandler(LineBasedFrameDecoder()))
                    .flatMap { channel.pipeline.addHandler(ScriptHandler(script: script)) }
            }
            .bind(host: "127.0.0.1", port: 0)
            .get()
        return FakeSMTPServer(group: group, channel: channel)
    }

    func stop() {
        try? channel.close().wait()
        try? group.syncShutdownGracefully()
    }

    private final class ScriptHandler: ChannelInboundHandler, @unchecked Sendable {

        typealias InboundIn = ByteBuffer

        private let script: Script

        init(script: @escaping Script) {
            self.script = script
        }

        func channelActive(context: ChannelHandlerContext) {
            script(context, nil)
        }

        func channelRead(context: ChannelHandlerContext, data: NIOAny) {
            var buffer = unwrapInboundIn(data)
            script(context, buffer.readString(length: buffer.readableBytes))
        }
    }
}

private extension ChannelHandlerContext {

    func writeLine(_ line: String) {
        writeAndFlush(NIOAny(channel.allocator.buffer(string: line + "\r\n")), promise: nil)
    }
}
