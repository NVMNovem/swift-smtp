//
//  ButtonStyle.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct ButtonStyle {
    
    public let background: Color
    public let foreground: Color
    public let cornerRadius: Int
    public let paddingVertical: Int
    public let paddingHorizontal: Int
    public let font: Font
    public let fontWeight: FontWeight

    public init(
        background: Color,
        foreground: Color,
        cornerRadius: Int,
        paddingVertical: Int,
        paddingHorizontal: Int,
        font: Font,
        fontWeight: FontWeight
    ) {
        self.background = background
        self.foreground = foreground
        self.cornerRadius = cornerRadius
        self.paddingVertical = paddingVertical
        self.paddingHorizontal = paddingHorizontal
        self.font = font
        self.fontWeight = fontWeight
    }

    public var css: String {
        [
            "display: inline-block",
            "text-decoration: none",
            "font-size: \(font.size)px",
            "line-height: \(font.lineHeight)px",
            "font-weight: \(fontWeight.rawValue)",
            "padding: \(paddingVertical)px \(paddingHorizontal)px",
            "border-radius: \(cornerRadius)px",
            "background: \(background.value)",
            "color: \(foreground.value)"
        ].joined(separator: "; ") + ";"
    }

    public static let `default` = ButtonStyle(
        background: .hex("#2563eb"),
        foreground: .hex("#ffffff"),
        cornerRadius: 8,
        paddingVertical: 12,
        paddingHorizontal: 18,
        font: .body,
        fontWeight: .bold
    )
}

extension ButtonStyle: Sendable {}
