//
//  Head.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct Head: HTMLNode {
    
    public let children: [HTMLNode]

    public init(_ children: [HTMLNode]) {
        self.children = children
    }

    public func render(into output: inout String, indent: Int) {
        HTMLElement(tag: "head", children: children).render(into: &output, indent: indent)
    }
}
