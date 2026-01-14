//
//  HeadBuilder.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 10/01/2026.
//

@resultBuilder
public enum HeadBuilder {
    
    public static func buildBlock(_ components: [HeadNode]...) -> [HeadNode] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: HeadNode) -> [HeadNode] {
        [expression]
    }
    
    public static func buildExpression(_ expression: String) -> [HeadNode] {
        return [HTMLText(expression)]
        
        struct HTMLText: HeadNode {
            
            public let value: String
            
            public init(_ value: String) {
                self.value = value
            }
            
            public func render(into output: inout String, indent: Int) {
                output += "\(String.indentation(indent))\(value.escapeHTML())\n"
            }
        }
    }

    public static func buildOptional(_ component: [HeadNode]?) -> [HeadNode] {
        component ?? []
    }

    public static func buildEither(first component: [HeadNode]) -> [HeadNode] {
        component
    }

    public static func buildEither(second component: [HeadNode]) -> [HeadNode] {
        component
    }

    public static func buildArray(_ components: [[HeadNode]]) -> [HeadNode] {
        components.flatMap { $0 }
    }
}
