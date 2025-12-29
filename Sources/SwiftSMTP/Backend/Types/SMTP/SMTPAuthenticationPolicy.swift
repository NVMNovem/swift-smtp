//
//  SMTPAuthenticationPolicy.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 29/12/2025.
//

public enum SMTPAuthenticationPolicy {
    
    case none
    case login(SMTPCredentials)
    case plain(SMTPCredentials)
    case xoauth2(token: String)
}

extension SMTPAuthenticationPolicy: Sendable {}

extension SMTPAuthenticationPolicy {
    
    internal var requiresTLS: Bool {
        switch self {
        case .none: false
        default: true
        }
    }
}
