//
//  CellBuilder.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

@resultBuilder
public enum CellBuilder {
    
    public static func buildBlock(_ components: [HTMLNode]...) -> [HTMLNode] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: HTMLNode) -> [HTMLNode] {
        [expression]
    }

    public static func buildExpression(_ expression: String) -> [HTMLNode] {
        [HTMLText(expression)]
    }

    public static func buildOptional(_ component: [HTMLNode]?) -> [HTMLNode] {
        component ?? []
    }

    public static func buildEither(first component: [HTMLNode]) -> [HTMLNode] {
        component
    }

    public static func buildEither(second component: [HTMLNode]) -> [HTMLNode] {
        component
    }

    public static func buildArray(_ components: [[HTMLNode]]) -> [HTMLNode] {
        components.flatMap { $0 }
    }
}
