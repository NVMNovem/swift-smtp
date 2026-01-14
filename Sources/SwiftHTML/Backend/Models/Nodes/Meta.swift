//
//  Meta.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 10/01/2026.
//

public struct Meta: BodyNode, HeadNode, Attributable {
    
    public var attributes: Attributes
    public let kind: Kind
    
    public enum Kind {
        
        case charset(String)
        case name(String, content: String? = nil)
    }

    public init(_ kind: Kind, attributes: Attributes = .empty) {
        self.kind = kind
        self.attributes = attributes
    }

    public func render(into output: inout String, indent: Int) {
        var attrs = attributes.disableSorting()

        switch kind {
        case let .charset(value):
            attrs["charset"] = value
        case let .name(name, content):
            attrs["name"] = name
            if let content {
                attrs["content"] = content
            }
        }

        HTMLElement(tag: "meta", attributes: attrs, isVoid: true).render(into: &output, indent: indent)
    }
}
