//
//  SMTPClient.swift
//  SwiftSMTP
//
//  Created by Damian Van de Kauter on 27/11/2025.
//

import Foundation

public final class Client {
    
    private let transport: Transport
    private let heloName: String
    private let authentication: SMTPAuthenticationPolicy
    
    private var state: SMTPState = .disconnected {
        didSet {
            print("SMTP State: \(state)")
        }
    }
    private var capabilities = SMTPCapabilities()
    
    public init(
        host: String,
        port: Int,
        heloName: String = "localhost",
        authentication: SMTPAuthenticationPolicy = .none
    ) {
        self.transport = Transport(host: host, port: port)
        self.heloName = heloName
        self.authentication = authentication
    }
}

public extension Client {
    
    func send(_ mails: Mail...) async throws {
        try await send(mails)
    }
    
    func send(_ mails: [Mail]) async throws {
        try await transport.connect()
        state = .connected
        
        let ehlo = try await sendCommand("EHLO \(heloName)", expecting: [250])
        capabilities = SMTPCapabilities(from: ehlo)
        state = .greeted
        
        if authentication.requiresTLS {
            guard capabilities.supportsStartTLS else {
                throw Error.invalidResponse("Server does not support STARTTLS")
            }
            
            try await sendCommand("STARTTLS", expecting: [220])
            try await transport.startTLS()
            state = .tlsEstablished
            
            let ehloTLS = try await sendCommand("EHLO \(heloName)", expecting: [250])
            capabilities = SMTPCapabilities(from: ehloTLS)
        }
        
        switch authentication {
        case .none:
            state = .authenticated
            
        case .login(let credentials):
            guard capabilities.authMechanisms.contains(.login) else {
                throw Error.invalidResponse("AUTH LOGIN not supported")
            }
            try await transport.authenticateLogin(
                username: credentials.username,
                password: credentials.password
            )
            state = .authenticated
            
        case .plain(let credentials):
            guard capabilities.authMechanisms.contains(.plain) else {
                throw Error.invalidResponse("AUTH PLAIN not supported")
            }
            try await transport.authenticatePlain(credentials)
            state = .authenticated
            
        case .xoauth2:
            throw Error.invalidResponse("XOAUTH2 not implemented")
        }
        
        for mail in mails {
            try await send(mail)
        }
        
        try await sendCommand("QUIT", expecting: [221])
        await transport.close()
        state = .disconnected
    }
}

private extension Client {
    
    func send(_ mail: Mail) async throws {
        guard state == .authenticated else {
            throw Error.invalidResponse("Cannot send mail before authentication")
        }
        try await sendCommand("MAIL FROM:\(mail.sender.formatted(includeName: false))", expecting: [250])
        state = .mailTransaction
        
        var failedRecipientErrors: [Swift.Error] = []
        let recipients = mail.receivers.all + mail.cc.all + mail.bcc.all
        for recipient in recipients {
            do {
                try await sendCommand("RCPT TO:\(recipient.formatted(includeName: false))", expecting: [250, 251])
            } catch {
                failedRecipientErrors.append(error)
            }
        }
        if !failedRecipientErrors.isEmpty {
            throw Error.invalidResponse("Some RCPT TO commands were rejected by server")
        }
        
        try await sendCommand("DATA", expecting: [354])
        
        let mimeData = buildMIMEData(from: mail)
        await transport.sendRaw(mimeData)
        
        await transport.sendLine(".")

        // Read final server response for DATA
        let response = try await transport.readResponse()
        guard response.code == 250 else {
            throw Error.invalidResponse(response.lines.joined(separator: "\n"))
        }
    }
    
    @discardableResult
    func sendCommand(
        _ command: String,
        expecting expectedCodes: [Int]
    ) async throws -> SMTPResponse {
        await transport.sendLine(command)
        let response = try await transport.readResponse()
        guard expectedCodes.contains(response.code) else {
            throw Error.invalidResponse(response.lines.joined(separator: "\n"))
        }
        let smtpResponse = SMTPResponse(code: response.code, lines: response.lines)
        
        print(smtpResponse.description)
        return smtpResponse
    }
    
    func buildMIMEData(from mail: Mail) -> Data {
        MIMEBuilder.build(mail, date: Date(), messageIDDomain: heloName)
    }
}
