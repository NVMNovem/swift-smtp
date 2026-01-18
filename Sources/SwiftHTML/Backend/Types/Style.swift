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
    case borderRadius(String)
    case borderBottom(String)
    case borderTop(String)
    case borderBottomLeftRadius(String)
    case borderBottomRightRadius(String)
    case borderTopLeftRadius(String)
    case borderTopRightRadius(String)
    case color(String)
    case display(String)
    case fontSize(String)
    case fontWeight(String)
    case fontFamily(String)
    case height(String)
    case lineHeight(String)
    case margin(String)
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
        case "border-radius": self = .borderRadius(cssValue)
        case "border-bottom": self = .borderBottom(cssValue)
        case "border-top": self = .borderTop(cssValue)
        case "border-bottom-left-radius": self = .borderBottomLeftRadius(cssValue)
        case "border-bottom-right-radius": self = .borderBottomRightRadius(cssValue)
        case "border-top-left-radius": self = .borderTopLeftRadius(cssValue)
        case "border-top-right-radius": self = .borderTopRightRadius(cssValue)
        case "color": self = .color(cssValue)
        case "display": self = .display(cssValue)
        case "font-size": self = .fontSize(cssValue)
        case "font-weight": self = .fontWeight(cssValue)
        case "font-family": self = .fontFamily(cssValue)
        case "height": self = .height(cssValue)
        case "line-height": self = .lineHeight(cssValue)
        case "margin": self = .margin(cssValue)
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
        case .background(let hex): "\(key): \(hex)"
        case .border(let size): "\(key): \(size)"
        case .borderCollapse(let state): "\(key): \(state)"
        case .borderRadius(let radius): "\(key): \(radius)"
        case .borderBottom(let border): "\(key): \(border)"
        case .borderTop(let border): "\(key): \(border)"
        case .borderBottomLeftRadius(let radius): "\(key): \(radius)"
        case .borderBottomRightRadius(let radius): "\(key): \(radius)"
        case .borderTopLeftRadius(let radius): "\(key): \(radius)"
        case .borderTopRightRadius(let radius): "\(key): \(radius)"
        case .color(let hex): "\(key): \(hex)"
        case .display(let type): "\(key): \(type)"
        case .fontSize(let size): "\(key): \(size)"
        case .fontWeight(let weight): "\(key): \(weight)"
        case .fontFamily(let family): "\(key): \(family)"
        case .height(let height): "\(key): \(height)"
        case .lineHeight(let height): "\(key): \(height)"
        case .margin(let margin): "\(key): \(margin)"
        case .maxWidth(let maxWidth): "\(key): \(maxWidth)"
        case .outline(let outline): "\(key): \(outline)"
        case .overflow(let state): "\(key): \(state)"
        case .padding(let padding): "\(key): \(padding)"
        case .textDecoration(let decoration): "\(key): \(decoration)"
        case .width(let width): "\(key): \(width)"
        }
    }
}

public extension Style {
    
    var key: String {
        switch self {
        case .background: "background"
        case .border: "border"
        case .borderCollapse: "border-collapse"
        case .borderRadius: "border-radius"
        case .borderBottom: "border-bottom"
        case .borderTop: "border-top"
        case .borderBottomLeftRadius: "border-bottom-left-radius"
        case .borderBottomRightRadius: "border-bottom-right-radius"
        case .borderTopLeftRadius: "border-top-left-radius"
        case .borderTopRightRadius: "border-top-right-radius"
        case .color: "color"
        case .display: "display"
        case .fontSize: "font-size"
        case .fontWeight: "font-weight"
        case .fontFamily: "font-family"
        case .height: "height"
        case .lineHeight: "line-height"
        case .margin: "margin"
        case .maxWidth: "max-width"
        case .outline: "outline"
        case .overflow: "overflow"
        case .padding: "padding"
        case .textDecoration: "text-decoration"
        case .width: "width"
        }
    }
}
