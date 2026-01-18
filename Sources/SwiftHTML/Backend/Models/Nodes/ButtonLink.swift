//
//  ButtonLink.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct ButtonLink: BodyNode, Attributable  {
    
    public let title: String
    public let destination: String
    public let style: ButtonStyle
    public var attributes: Attributes

    public init(_ title: String, destination: String, style: ButtonStyle = .default, attributes: Attributes = .empty) {
        self.title = title
        self.destination = destination
        self.style = style
        self.attributes = attributes
    }

    public func render(into output: inout String, indent: Int) {
        let link = Link(title, destination: destination)
            .style(.button(style))
            .style("display: inline-block;")

        let td = HTMLElement(
            tag: "td",
            attributes: attributes + [
                "bgcolor": style.background.value,
                "style": "border-radius: \(style.cornerRadius)px;"
            ],
            children: [link]
        )

        let row = HTMLElement(tag: "tr", children: [td])
        let table = HTMLElement(
            tag: "table",
            attributes: [
                "role": Role.presentation.rawValue,
                "cellpadding": "0",
                "cellspacing": "0",
                "border": "0"
            ],
            children: [row]
        )

        table.render(into: &output, indent: indent)
    }
}
