//
//  RawHTML.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct RawHTML: BodyNode, Attributable {
    
    public let value: String
    public var attributes: Attributes

    public init(_ value: String, attributes: Attributes = .empty,) {
        self.value = value
        self.attributes = attributes
    }

    public func render(into output: inout String, indent: Int) {
        let lines = value.split(separator: "\n", omittingEmptySubsequences: false)
        for line in lines {
            output += "\(String.indentation(indent))\(line)\n"
        }
    }
}
