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
    private let useTLS: Bool
    
    public init(
        host: String,
        port: Int,
        heloName: String = "localhost",
        useTLS: Bool = false
    ) {
        self.transport = Transport(host: host, port: port)
        self.heloName = heloName
        self.useTLS = useTLS
    }
}

public extension Client {
    
    func send(_ mails: Mail...) async throws {
        try await transport.connect()
        
        try await sendCommand("EHLO \(heloName)")
        
        if useTLS {
            try await sendCommand("STARTTLS")
            try await transport.startTLS()
            
            try await sendCommand("EHLO \(heloName)")
        }
        
        for mail in mails {
            try await send(mail)
        }
        
        try await sendCommand("QUIT")
        await transport.close()
    }
}

private extension Client {
    
    func send(_ mail: Mail) async throws {
        try await sendCommand("MAIL FROM:\(mail.sender.formatted())")
        try await sendCommand("RCPT TO:\(mail.receiver.formatted())")
        try await sendCommand("DATA")
        try await sendCommand(mail.formatted())
        try await sendCommand(".")
    }
    
    func sendCommand(_ command: String) async throws {
        await transport.sendLine(command)
        let response = try await transport.readLine()
        guard response.hasPrefix("2") || response.hasPrefix("3")
        else { throw Error.invalidResponse(response) }
    }
}
