//
//  SMTPCredentials.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 29/12/2025.
//

public struct SMTPCredentials {
    
    let username: String
    let password: String
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}

extension SMTPCredentials: Sendable {}
