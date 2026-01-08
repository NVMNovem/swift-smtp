//
//  HTMLElement.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct HTMLElement: HTMLNode {
    
    public let tag: String
    public let attributes: Attributes
    public let children: [HTMLNode]
    public let isVoid: Bool

    public init(
        tag: String,
        attributes: Attributes = .empty,
        children: [HTMLNode] = [],
        isVoid: Bool = false
    ) {
        self.tag = tag
        self.attributes = attributes
        self.children = children
        self.isVoid = isVoid
    }

    public func render(into output: inout String, indent: Int) {
        let indentValue = String.indentation(indent)
        let attrs = attributes.render()

        if isVoid {
            output += "\(indentValue)<\(tag)\(attrs)>\n"
            return
        }

        if children.isEmpty {
            output += "\(indentValue)<\(tag)\(attrs)></\(tag)>\n"
            return
        }

        output += "\(indentValue)<\(tag)\(attrs)>\n"
        for child in children {
            child.render(into: &output, indent: indent + 1)
        }
        output += "\(indentValue)</\(tag)>\n"
    }
}
