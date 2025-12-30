//
//  SMTPState.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 29/12/2025.
//

internal enum SMTPState {
    
    case disconnected
    case connected
    case greeted
    case tlsEstablished
    case authenticated
    case mailTransaction
}

extension SMTPState: Sendable {}
