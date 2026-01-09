//
//  HTMLDocument.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct HTMLDocument: HTMLNode {
    
    public private(set) var languageCode: String
    public private(set) var children: [HTMLNode]

    public init(
        languageCode: String = "en",
        @HTMLBuilder content: () -> [HTMLNode]
    ) {
        self.languageCode = languageCode
        self.children = content()
    }

    public func render(into output: inout String, indent: Int) {
        output += "<!doctype html>\n"
        
        HTMLElement(tag: "html", attributes: ["lang": languageCode], children: children)
            .render(into: &output, indent: indent)
    }
}

public extension HTMLDocument {
    
    func language(_ languageCode: String) -> HTMLDocument {
        var copy = self
        copy.languageCode = languageCode
        return copy
    }
}
