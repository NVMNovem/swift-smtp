//
//  Br.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct Br: HTMLNode {
    
    public init() {}

    public func render(into output: inout String, indent: Int) {
        HTMLElement(tag: "br", isVoid: true).render(into: &output, indent: indent)
    }
}
