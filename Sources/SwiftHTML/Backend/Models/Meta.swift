//
//  Meta.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct Meta: HTMLNode {
    
    public let attributes: Attributes

    public init(_ attributes: Attributes) {
        self.attributes = attributes
    }

    public func render(into output: inout String, indent: Int) {
        HTMLElement(tag: "meta", attributes: attributes, isVoid: true).render(into: &output, indent: indent)
    }
}
