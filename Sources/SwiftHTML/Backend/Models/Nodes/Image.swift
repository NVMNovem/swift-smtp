//
//  Image.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct Image: BodyNode, Attributable, Frameable {

    public var attributes: Attributes

    public init(src: String, alt: String, width: Int? = nil) {
        var attrs: Attributes = ["src": src, "alt": alt]
        
        if let width {
            attrs["width"] = "\(width)"
        }
        
        self.attributes = attrs
    }

    public func render(into output: inout String, indent: Int) {
        HTMLElement(tag: "img", attributes: attributes, isVoid: true).render(into: &output, indent: indent)
    }
}
