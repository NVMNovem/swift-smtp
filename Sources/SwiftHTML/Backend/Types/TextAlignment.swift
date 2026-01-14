//
//  TextAlignment.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public enum TextAlignment {
    
    case leading
    case center
    case trailing

    var cssValue: String {
        switch self {
        case .leading: return "left"
        case .center: return "center"
        case .trailing: return "right"
        }
    }
}
