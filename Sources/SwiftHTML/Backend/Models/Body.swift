//
//  Body.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct Body: HTMLNode, Attributable {
    
    public var attributes: Attributes
    public let children: [HTMLNode]

    public init(attributes: Attributes = .empty, @HTMLBuilder _ content: () -> [HTMLNode]) {
        self.attributes = attributes
        self.children = content()
    }

    public func render(into output: inout String, indent: Int) {
        HTMLElement(tag: "body", attributes: attributes, children: children).render(into: &output, indent: indent)
    }
}
