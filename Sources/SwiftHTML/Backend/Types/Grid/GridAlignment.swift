//
//  GridAlignment.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 08/01/2026.
//
    
public enum GridAlignment {
    
    case leading
    case center
    case trailing
    
    var htmlAlign: String {
        switch self {
        case .leading: return "left"
        case .center: return "center"
        case .trailing: return "right"
        }
    }
}

extension GridAlignment: Sendable {}
