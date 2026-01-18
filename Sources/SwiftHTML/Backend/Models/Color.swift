//
//  Color.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct Color {
    
    public let value: String

    public init(_ value: String) {
        self.value = value
    }

    public static func hex(_ value: String) -> Color {
        Color(value)
    }
}

extension Color: Sendable {}
