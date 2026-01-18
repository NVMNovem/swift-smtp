//
//  Title.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 10/01/2026.
//

public struct Title: BodyNode, HeadNode {
    
    public let title: String

    public init(_ title: String) {
        self.title = title
    }

    public func render(into output: inout String, indent: Int) {
        HTMLElement(tag: "title", children: [HTMLText(title)]).render(into: &output, indent: indent)
    }
}
