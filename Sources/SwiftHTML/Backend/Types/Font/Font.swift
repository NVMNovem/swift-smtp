//
//  Font.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public enum Font {
    
    case title2
    case title3
    case body
    case caption
    case footnote

    public var size: Int {
        switch self {
        case .title2: return 22
        case .title3: return 20
        case .body: return 16
        case .caption: return 13
        case .footnote: return 12
        }
    }

    public var lineHeight: Int {
        switch self {
        case .title2: return 30
        case .title3: return 28
        case .body: return 24
        case .caption: return 18
        case .footnote: return 16
        }
    }
}

extension Font: Sendable {}
