//
//  Markdown.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct Markdown: ExpressibleByStringLiteral {
    
    internal let value: String
    
    public init(_ value: String) {
        self.value = value
    }
    
    public init(stringLiteral value: String) {
        self.value = value
    }
}

extension Markdown: Sendable {}
