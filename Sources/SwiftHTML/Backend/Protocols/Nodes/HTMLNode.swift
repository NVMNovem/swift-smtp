//
//  HTMLNode.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public protocol HTMLNode {
    
    func render(into output: inout String, indent: Int)
}

public extension HTMLNode {
    
    func render() -> String {
        var output = ""
        render(into: &output, indent: 0)
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

internal extension Array where Element == HTMLNode {
    
    var inlinedText: [HTMLNode] {
        map { node -> Element in
            if let textNode = node as? Text {
                return textNode.inlined()
            } else {
                return node
            }
        }
    }
}
