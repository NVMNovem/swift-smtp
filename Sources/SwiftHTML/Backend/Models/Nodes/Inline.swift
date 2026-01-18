//
//  Inline.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct Inline: BodyNode, Attributable {
    
    public var attributes: Attributes
    public let children: [HTMLNode]

    public init(attributes: Attributes = .empty, @HTMLBuilder _ content: () -> [HTMLNode]) {
        self.attributes = attributes
        self.children = content().inlinedText
    }

    public func render(into output: inout String, indent: Int) {
        HTMLElement(tag: "span", attributes: attributes, children: children, renderMode: .inline)
            .render(into: &output, indent: indent)
    }
}
