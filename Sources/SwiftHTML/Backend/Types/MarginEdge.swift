//
//  MarginEdge.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public enum MarginEdge {
    
    case top
    case bottom
    case leading
    case trailing

    var cssValue: String {
        switch self {
        case .top: return "top"
        case .bottom: return "bottom"
        case .leading: return "left"
        case .trailing: return "right"
        }
    }
}
