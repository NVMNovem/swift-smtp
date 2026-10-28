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

@Test(arguments: [0, 1, 2, 3])
func authenticationRejectionPreservesDiagnostics(step: Int) async throws {
    let username = "fake-user@example.test"
    let password = "fake-password-ONLY"
    let userPayload = Data(username.utf8).base64EncodedString()
    let server = try await FakeSMTPServer.start { context, line in
        guard let line else {
            context.writeLine("220 fake ESMTP")
            return
        }
        if (step == 0 && line == "AUTH LOGIN") ||
            (step == 1 && line == userPayload) ||
            (step == 2 && line == Data(password.utf8).base64EncodedString()) || step == 3 {
            context.writeLine("535-5.7.8 Authentication failed")
            context.writeLine("535 5.7.8 Invalid credentials")
        } else {
            context.writeLine("334 challenge")
        }
    }
    defer { server.stop() }
    let transport = Transport(host: "127.0.0.1", port: server.port, connectTimeout: .seconds(5), responseTimeout: .seconds(5))
    try await transport.connect()
    do {
        if step == 3 {
            try await transport.authenticatePlain(SMTPCredentials(username: username, password: password))
        } else {
            try await transport.authenticateLogin(username: username, password: password)
        }
        Issue.record("Expected authentication rejection")
    } catch let error as SMTPAuthenticationError {
        #expect(error.mechanism == (step == 3 ? .plain : .login))
        let stages: [SMTPAuthenticationError.Stage] = [.initialCommand, .usernameChallenge, .credentialsVerification, .credentialsVerification]
        #expect(error.stage == stages[step])
        #expect(error.responseCode == 535)
        #expect(error.enhancedStatusCode == "5.7.8")
        #expect(error.responseText.contains("Authentication failed"))
        #expect(error.responseText.contains("Invalid credentials"))
        #expect(String(describing: error).contains(error.mechanism.rawValue))
        #expect(error.localizedDescription.contains(error.stage.rawValue))
        #expect(error.localizedDescription.contains("535 (5.7.8)"))
        #expect(error.localizedDescription == String(describing: error))
    } catch {
        await transport.close()
        throw error
    }
    await transport.close()
}

@Test(arguments: [false, true])
func authenticationRedactsUntrustedReplies(plain: Bool) async throws {
    let username = "fake-user@example.test"
    let password = "fake-password-ONLY"
    let payload = Data("\u{0}\(username)\u{0}\(password)".utf8).base64EncodedString()
    let server = try await FakeSMTPServer.start { context, line in
        guard let line else {
            context.writeLine("220 fake ESMTP")
            return
        }
        context.writeLine("535-5.7.8 Invalid credentials \(username) \(password) \(Data(password.utf8).base64EncodedString()) \(payload)")
        context.writeLine("535-\(Data(username.utf8).base64EncodedString()) \(payload.replacingOccurrences(of: "=", with: ""))")
        context.writeLine("535-AUTH PLAIN \(payload)")
        context.writeLine("535-AUTH LOGIN")
        context.writeLine("535-\(line)")
        context.writeLine("535-unknown-token-value secret@example.test \u{1B}[31m\u{0} \u{202E}danger")
        context.writeLine("535 " + String(repeating: "Invalid credentials ", count: 100))
    }
    defer { server.stop() }
    let transport = Transport(host: "127.0.0.1", port: server.port, connectTimeout: .seconds(5), responseTimeout: .seconds(5))
    try await transport.connect()
    do {
        if plain {
            try await transport.authenticatePlain(SMTPCredentials(username: username, password: password))
        } else {
            try await transport.authenticateLogin(username: username, password: password)
        }
        Issue.record("Expected authentication rejection")
    } catch let error as SMTPAuthenticationError {
        #expect(error.responseText.utf8.count <= 512)
        #expect(error.responseText.hasSuffix("..."))
        #expect(error.responseText.contains("[redacted]"))
        #expect(error.responseText.unicodeScalars.allSatisfy { (32...126).contains($0.value) })
        for secret in [username, password, payload, payload.replacingOccurrences(of: "=", with: ""), Data(username.utf8).base64EncodedString(), Data(password.utf8).base64EncodedString(), "AUTH LOGIN", "AUTH PLAIN", "unknown-token-value", "secret@example.test"] {
            #expect(!error.responseText.contains(secret))
            #expect(!String(describing: error).contains(secret))
            #expect(!error.localizedDescription.contains(secret))
            #expect(!String(reflecting: error).contains(secret))
        }
    } catch {
        await transport.close()
        throw error
    }
    await transport.close()
}

@Test(arguments: [false, true])
func authenticationSuccessKeepsWireExchange(plain: Bool) async throws {
    let username = "local-user"
    let password = "local-password"
    let payload = Data("\u{0}\(username)\u{0}\(password)".utf8).base64EncodedString()
    let server = try await FakeSMTPServer.start { context, line in
        switch line {
        case nil: context.writeLine("220 fake ESMTP")
        case "AUTH LOGIN": context.writeLine("334 VXNlcm5hbWU6")
        case Data(username.utf8).base64EncodedString(): context.writeLine("334 UGFzc3dvcmQ6")
        case Data(password.utf8).base64EncodedString(), "AUTH PLAIN \(payload)": context.writeLine("235 2.7.0 Authentication successful")
        case "NOOP": context.writeLine("250 OK")
        default: context.writeLine("500 Unexpected command")
        }
    }
    defer { server.stop() }
    let transport = Transport(host: "127.0.0.1", port: server.port, connectTimeout: .seconds(5), responseTimeout: .seconds(5))
    try await transport.connect()
    do {
        if plain {
            try await transport.authenticatePlain(SMTPCredentials(username: username, password: password))
        } else {
            try await transport.authenticateLogin(username: username, password: password)
        }
        await transport.sendLine("NOOP")
        let response = try await transport.readResponse()
        #expect(response.code == 250)
    } catch {
        await transport.close()
        throw error
    }
    await transport.close()
}

@Test(arguments: ["454 Temporary authentication failure", "535 5.7.999 Invalid credentials", "535 Invalid credentials 5.7.8", "535 5.7.9999 Invalid credentials"])
func authenticationEnhancedStatusParsing(reply: String) {
    let error = SMTPAuthenticationError(mechanism: .login, stage: .initialCommand,
                                       response: (Int(reply.prefix(3))!, [reply]), username: "fake-user", password: "fake-password")
    #expect(error.responseCode == Int(reply.prefix(3)))
    #expect(error.enhancedStatusCode == (reply.contains("5.7.999 ") ? "5.7.999" : nil))
}

@Test
func authenticationRedactsBeforeTruncation() {
    let password = String(repeating: "x", count: 700)
    let error = SMTPAuthenticationError(mechanism: .plain, stage: .credentialsVerification,
                                       response: (535, ["535 Invalid credentials " + password]), username: "fake-user", password: password)
    #expect(error.responseText == "Invalid credentials [redacted]")
    #expect(!error.description.contains("xxx"))
}

@Test
func authenticationFindsEnhancedStatusOnLaterLine() {
    let error = SMTPAuthenticationError(mechanism: .plain, stage: .credentialsVerification,
                                       response: (454, ["454-Temporary authentication failure", "454 4.7.0 Please try later"]),
                                       username: "", password: "")
    #expect(error.responseCode == 454)
    #expect(error.enhancedStatusCode == "4.7.0")
    #expect(error.description.contains("454 (4.7.0)"))
    #expect(error.responseText.contains("Temporary authentication failure"))
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
