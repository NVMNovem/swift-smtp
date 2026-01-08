//
//  Grid.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct Grid: HTMLNode, Attributable {
    
    public var attributes: Attributes
    public let rows: [HTMLNode]

    public init(
        role: Role? = .presentation,
        width: String? = "100%",
        cellpadding: Int = 0,
        cellspacing: Int = 0,
        border: Int = 0,
        attributes: Attributes = .empty,
        @HTMLBuilder _ content: () -> [HTMLNode]
    ) {
        var attrs = attributes
        if let role {
            attrs["role"] = role.rawValue
        }
        if let width {
            attrs["width"] = width
        }
        attrs["cellpadding"] = "\(cellpadding)"
        attrs["cellspacing"] = "\(cellspacing)"
        attrs["border"] = "\(border)"
        self.attributes = attrs
        self.rows = content()
    }

    public func render(into output: inout String, indent: Int) {
        HTMLElement(tag: "table", attributes: attributes, children: rows).render(into: &output, indent: indent)
    }
}
