//
//  CSS.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 13/01/2026.
//

public struct CSS: ExpressibleByStringLiteral, ExpressibleByStringInterpolation, ExpressibleByArrayLiteral {
    
    internal let styles: [Style]
    
    public init(_ styles: Style...) {
        self.styles = styles
    }
    
    public init(stringLiteral value: String) {
        let cssStrings = value
            .split(separator: ";")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        self.styles = cssStrings.compactMap { Style(css: $0) }
    }
    
    public init(arrayLiteral elements: Style...) {
        self.styles = elements
    }
    
    public init(stringInterpolation: String) {
        self.init(stringLiteral: stringInterpolation)
    }
}

extension CSS: Sendable {}
