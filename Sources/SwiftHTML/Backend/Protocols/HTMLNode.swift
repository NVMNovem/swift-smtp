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
        if output.hasSuffix("\n") {
            output.removeLast()
        }
        return output
    }
}
