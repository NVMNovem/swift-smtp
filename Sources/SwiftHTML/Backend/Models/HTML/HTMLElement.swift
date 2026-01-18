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
    public let renderMode: RenderMode
    public let isVoid: Bool
    
    public init(
        tag: String,
        attributes: Attributes = .empty,
        children: [HTMLNode] = [],
        isVoid: Bool = false,
        renderMode: RenderMode = .automatic
    ) {
        self.tag = tag
        self.attributes = attributes
        self.children = children
        self.isVoid = isVoid
        self.renderMode = renderMode
    }
    
    private var resolvedRenderMode: RenderMode {
        switch renderMode {
        case .inline, .block:
            return renderMode
        case .automatic:
            switch tag.lowercased() {
            case "span", "a", "strong", "em", "b", "i", "u", "small", "s", "mark",
                "code", "kbd", "samp", "var", "sub", "sup", "abbr", "cite", "q", "time",
                "label", "button":
                return .inline
            default:
                return .block
            }
        }
    }
    
    public func render(into output: inout String, indent: Int) {
        let attrs = attributes.render()
        
        if resolvedRenderMode == .inline {
            if isVoid {
                output += "<\(tag)\(attrs)>"
                return
            }
            
            if children.isEmpty {
                output += "<\(tag)\(attrs)></\(tag)>"
                return
            }
            
            output += "<\(tag)\(attrs)>"
            for child in children {
                child.render(into: &output, indent: 0)
            }
            output += "</\(tag)>"
            return
        }
        
        let indentValue = String.indentation(indent)

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
