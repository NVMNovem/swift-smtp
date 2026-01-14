//
//  GridRowCell.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 13/01/2026.
//

public struct GridRowCell: BodyNode, Attributable {
    
    public var attributes: Attributes
    public let children: [HTMLNode]

    public init(
        alignment: GridAlignment = .leading,
        colspan: Int? = nil,
        rowspan: Int? = nil,
        valign: String? = nil,
        height: Int? = nil,
        attributes: Attributes = .empty,
        @HTMLBuilder _ content: () -> [HTMLNode]
    ) {
        var attrs = attributes
        attrs["align"] = alignment.htmlAlign
        if let colspan {
            attrs["colspan"] = "\(colspan)"
        }
        if let rowspan {
            attrs["rowspan"] = "\(rowspan)"
        }
        if let valign {
            attrs["valign"] = valign
        }
        if let height {
            attrs["height"] = "\(height)"
        }
        self.attributes = attrs
        self.children = content()
    }

    public func render(into output: inout String, indent: Int) {
        let cell = HTMLElement(tag: "td", attributes: attributes, children: children)
        HTMLElement(tag: "tr", children: [cell]).render(into: &output, indent: indent)
    }
}
