//
//  Title.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct Title: HTMLNode {
    
    public let value: String

    public init(_ value: String) {
        self.value = value
    }

    public func render(into output: inout String, indent: Int) {
        HTMLElement(tag: "title", children: [HTMLText(value)]).render(into: &output, indent: indent)
    }
}
