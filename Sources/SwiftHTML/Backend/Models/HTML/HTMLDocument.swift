//
//  HTMLDocument.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct HTMLDocument: HTMLNode {
    
    public let lang: String
    public let children: [HTMLNode]

    public init(lang: String = "en", @HTMLBuilder content: () -> [HTMLNode]) {
        self.lang = lang
        self.children = content()
    }

    public func render(into output: inout String, indent: Int) {
        output += "<!doctype html>\n"
        HTMLElement(tag: "html", attributes: ["lang": lang], children: children).render(into: &output, indent: indent)
    }
}
