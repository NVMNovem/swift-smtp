//
//  AuthMechanism.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 29/12/2025.
//

internal enum AuthMechanism {
    
    case login
    case plain
    case xoauth2
}

extension AuthMechanism: Sendable {}
