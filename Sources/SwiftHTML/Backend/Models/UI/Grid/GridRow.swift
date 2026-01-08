//
//  GridRow.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct GridRow: HTMLNode {
    
    public let cells: [HTMLNode]

    public init(@HTMLBuilder _ content: () -> [HTMLNode]) {
        self.cells = content()
    }

    public func render(into output: inout String, indent: Int) {
        HTMLElement(tag: "tr", children: cells).render(into: &output, indent: indent)
    }
}
