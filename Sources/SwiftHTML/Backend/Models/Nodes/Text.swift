//
//  Text.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct Text: BodyNode, Attributable {
    
    public var attributes: Attributes
    public let nodes: [HTMLNode]

    public init(_ value: String) {
        self.attributes = [:]
        self.nodes = [HTMLText(value)]
    }
    
    public init(@TextBuilder _ content: () -> [HTMLNode]) {
        self.attributes = [:]
        self.nodes = content()
    }

    public init(markdown: Markdown) {
        self.attributes = [:]
        self.nodes = [RawHTML(markdown.render())]
    }

    public func render(into output: inout String, indent: Int) {
        HTMLElement(tag: "div", attributes: attributes, children: nodes).render(into: &output, indent: indent)
    }
}

public extension Text {
    
    func font(_ font: Font) -> Text {
        var copy = self
        let style = "font-size: \(font.size)px; line-height: \(font.lineHeight)px;"
        copy.attributes["style"] = copy.attributes["style"].appendStyle(style)
        return copy
    }

    func fontWeight(_ weight: FontWeight) -> Text {
        var copy = self
        let style = "font-weight: \(weight.rawValue);"
        copy.attributes["style"] = copy.attributes["style"].appendStyle(style)
        return copy
    }

    func foregroundColor(_ color: Color) -> Text {
        var copy = self
        let style = "color: \(color.value);"
        copy.attributes["style"] = copy.attributes["style"].appendStyle(style)
        return copy
    }

    func backgroundColor(_ color: Color) -> Text {
        var copy = self
        let style = "background-color: \(color.value);"
        copy.attributes["style"] = copy.attributes["style"].appendStyle(style)
        return copy
    }

    func textAlignment(_ alignment: TextAlignment) -> Text {
        var copy = self
        let style = "text-align: \(alignment.cssValue);"
        copy.attributes["style"] = copy.attributes["style"].appendStyle(style)
        return copy
    }

    func margin(_ edge: MarginEdge, _ spacing: Spacing) -> Text {
        var copy = self
        let style = "margin-\(edge.cssValue): \(spacing.px)px;"
        copy.attributes["style"] = copy.attributes["style"].appendStyle(style)
        return copy
    }

    func padding(_ edge: MarginEdge, _ spacing: Spacing) -> Text {
        var copy = self
        let style = "padding-\(edge.cssValue): \(spacing.px)px;"
        copy.attributes["style"] = copy.attributes["style"].appendStyle(style)
        return copy
    }
}
