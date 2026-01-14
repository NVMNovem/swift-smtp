//
//  FontWeight.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public enum FontWeight: String {
    
    case regular = "400"
    case medium = "500"
    case semibold = "600"
    case bold = "700"
}

extension FontWeight: Sendable {}
