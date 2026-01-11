//
//  Column.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct Column {
    
    public let title: String
    public let alignment: GridAlignment

    public init(_ title: String, alignment: GridAlignment = .leading) {
        self.title = title
        self.alignment = alignment
    }
}
