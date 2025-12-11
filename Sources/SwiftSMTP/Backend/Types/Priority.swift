//
//  Priority.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 11/12/2025.
//

public enum Priority {
    
    case low
    case normal
    case high
}

extension Priority: Sendable {}
