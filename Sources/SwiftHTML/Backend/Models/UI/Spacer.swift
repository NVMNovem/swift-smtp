//
//  Spacer.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct Spacer: HTMLNode {
    
    public let height: Int

    public init(height: Int) {
        self.height = height
    }

    public func render(into output: inout String, indent: Int) {
        let style = "height: \(height)px; line-height: \(height)px;"
        HTMLElement(tag: "div", attributes: ["style": style], children: [RawHTML("&nbsp;")]).render(into: &output, indent: indent)
    }
}
