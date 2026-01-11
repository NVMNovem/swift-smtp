//
//  BodyBuilder.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

@resultBuilder
public enum BodyBuilder {
    
    public static func buildBlock(_ components: [BodyNode]...) -> [BodyNode] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: BodyNode) -> [BodyNode] {
        [expression]
    }

    public static func buildExpression(_ expression: String) -> [BodyNode] {
        return [HTMLText(expression)]
        
        struct HTMLText: BodyNode {
            
            public let value: String
            
            public init(_ value: String) {
                self.value = value
            }
            
            public func render(into output: inout String, indent: Int) {
                output += "\(String.indentation(indent))\(value.escapeHTML())\n"
            }
        }
    }

    public static func buildOptional(_ component: [BodyNode]?) -> [BodyNode] {
        component ?? []
    }

    public static func buildEither(first component: [BodyNode]) -> [BodyNode] {
        component
    }

    public static func buildEither(second component: [BodyNode]) -> [BodyNode] {
        component
    }

    public static func buildArray(_ components: [[BodyNode]]) -> [BodyNode] {
        components.flatMap { $0 }
    }
}
