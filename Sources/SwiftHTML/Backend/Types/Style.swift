//
//  Style.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 13/01/2026.
//

import Foundation

public enum Style {
    
    case background(String)
    case border(String)
    case borderCollapse(String)
    case color(String)
    case display(String)
    case fontSize(String)
    case fontWeight(String)
    case fontFamily(String)
    case height(String)
    case lineHeight(String)
    case maxWidth(String)
    case outline(String)
    case overflow(String)
    case padding(String)
    case textDecoration(String)
    case width(String)
}

extension Style: Sendable {}

extension Style {
    
    public init?(css: String) {
        guard let colonIndex = css.firstIndex(of: ":") else { return nil }
        let cssKey = css[..<colonIndex]
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let cssValue = css[css.index(after: colonIndex)...]
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: ";"))
        
        switch cssKey {
        case "background": self = .background(cssValue)
        case "border": self = .border(cssValue)
        case "border-collapse": self = .borderCollapse(cssValue)
        case "color": self = .color(cssValue)
        case "display": self = .display(cssValue)
        case "font-size": self = .fontSize(cssValue)
        case "font-weight": self = .fontWeight(cssValue)
        case "font-family": self = .fontFamily(cssValue)
        case "height": self = .height(cssValue)
        case "line-height": self = .lineHeight(cssValue)
        case "max-width": self = .maxWidth(cssValue)
        case "outline": self = .outline(cssValue)
        case "overflow": self = .overflow(cssValue)
        case "padding": self = .padding(cssValue)
        case "text-decoration": self = .textDecoration(cssValue)
        case "width": self = .width(cssValue)
        default: return nil
        }
    }
    
    public var css: String {
        switch self {
        case .background(let hex): "\(key): \(hex);"
        case .border(let size): "\(key): \(size);"
        case .borderCollapse(let state): "\(key): \(state);"
        case .color(let hex): "\(key): \(hex);"
        case .display(let type): "\(key): \(type);"
        case .fontSize(let size): "\(key): \(size);"
        case .fontWeight(let weight): "\(key): \(weight);"
        case .fontFamily(let family): "\(key): \(family);"
        case .height(let height): "\(key): \(height);"
        case .lineHeight(let padding): "\(key): \(padding);"
        case .maxWidth(let maxWidth): "\(key): \(maxWidth);"
        case .outline(let outline): "\(key): \(outline);"
        case .overflow(let state): "\(key): \(state);"
        case .padding(let padding): "\(key): \(padding);"
        case .textDecoration(let decoration): "\(key): \(decoration);"
        case .width(let width): "\(key): \(width);"
        }
    }
}

public extension Style {
    
    var key: String {
        switch self {
        case .background: "background"
        case .border: "border"
        case .borderCollapse: "border-collapse"
        case .color: "color"
        case .display: "display"
        case .fontSize: "font-size"
        case .fontWeight: "font-weight"
        case .fontFamily: "font-family"
        case .height: "height"
        case .lineHeight: "line-height"
        case .maxWidth: "max-width"
        case .outline: "outline"
        case .overflow: "overflow"
        case .padding: "padding"
        case .textDecoration: "text-decoration"
        case .width: "width"
        }
    }
}
