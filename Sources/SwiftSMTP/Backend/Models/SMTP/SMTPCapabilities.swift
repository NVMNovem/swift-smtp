//
//  SMTPCapabilities.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 29/12/2025.
//

internal struct SMTPCapabilities {
    
    var supportsStartTLS: Bool = false
    var authMechanisms: Set<AuthMechanism> = []
    
    internal init() {
        self.supportsStartTLS = false
        self.authMechanisms = []
    }
    
    internal init(from response: SMTPResponse) {
        self.supportsStartTLS = false
        self.authMechanisms = []
        
        for line in response.lines {
            let upper = line.uppercased()
            
            if upper.contains("STARTTLS") {
                supportsStartTLS = true
            }
            
            if upper.contains("AUTH ") {
                if upper.contains("LOGIN") {
                    authMechanisms.insert(.login)
                }
                if upper.contains("PLAIN") {
                    authMechanisms.insert(.plain)
                }
                if upper.contains("XOAUTH2") {
                    authMechanisms.insert(.xoauth2)
                }
            }
        }
    }
}

extension SMTPCapabilities: Sendable {}
