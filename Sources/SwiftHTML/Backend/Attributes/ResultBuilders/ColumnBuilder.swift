//
//  ColumnBuilder.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

@resultBuilder
public enum ColumnBuilder {
    
    public static func buildBlock(_ components: [Column]...) -> [Column] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: Column) -> [Column] {
        [expression]
    }

    public static func buildOptional(_ component: [Column]?) -> [Column] {
        component ?? []
    }

    public static func buildEither(first component: [Column]) -> [Column] {
        component
    }

    public static func buildEither(second component: [Column]) -> [Column] {
        component
    }

    public static func buildArray(_ components: [[Column]]) -> [Column] {
        components.flatMap { $0 }
    }
}
