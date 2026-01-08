//
//  Link.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct Link: HTMLNode, Attributable {
    
    public var attributes: Attributes
    public let destination: String
    public let children: [HTMLNode]
    public let linkStyle: LinkStyle

    public init(_ title: String, destination: String) {
        self.destination = destination
        self.children = [HTMLText(title)]
        self.attributes = [:]
        self.linkStyle = .plain
    }

    public init(destination: String, @HTMLBuilder _ content: () -> [HTMLNode]) {
        self.destination = destination
        self.children = content()
        self.attributes = [:]
        self.linkStyle = .plain
    }

    private init(destination: String, children: [HTMLNode], attributes: Attributes, linkStyle: LinkStyle) {
        self.destination = destination
        self.children = children
        self.attributes = attributes
        self.linkStyle = linkStyle
    }

    public func style(_ style: LinkStyle) -> Link {
        Link(destination: destination, children: children, attributes: attributes, linkStyle: style)
    }

    public func render(into output: inout String, indent: Int) {
        var attrs = attributes
        attrs["href"] = destination
        if case let .button(buttonStyle) = linkStyle {
            let style = buttonStyle.css
            attrs["style"] = attrs["style"].appendStyle(style)
        }
        HTMLElement(tag: "a", attributes: attrs, children: children).render(into: &output, indent: indent)
    }
}
