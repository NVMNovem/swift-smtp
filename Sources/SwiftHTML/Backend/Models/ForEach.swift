//
//  ForEach.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct ForEach<Data: RandomAccessCollection>: HTMLNode {
    
    public let data: Data
    public let renderer: (Data.Element, Int) -> [HTMLNode]

    public init(_ data: Data, @HTMLBuilder content: @escaping (Data.Element) -> [HTMLNode]) {
        self.data = data
        self.renderer = { element, _ in content(element) }
    }

    public init(_ data: Data, @HTMLBuilder content: @escaping (Data.Element, Int) -> [HTMLNode]) {
        self.data = data
        self.renderer = content
    }

    public func render(into output: inout String, indent: Int) {
        var index = 0
        for element in data {
            let nodes = renderer(element, index)
            for node in nodes {
                node.render(into: &output, indent: indent)
            }
            index += 1
        }
    }
}
