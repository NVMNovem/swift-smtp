//
//  Body.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct Body: HTMLNode, Attributable {
    
    public let children: [HTMLNode]
    public var attributes: Attributes
    
    public init(_ children: [HTMLNode], attributes: Attributes = .empty) {
        self.children = children
        self.attributes = attributes
    }
    
    public func render(into output: inout String, indent: Int) {
        HTMLElement(tag: "body", attributes: attributes, children: children).render(into: &output, indent: indent)
    }
}
