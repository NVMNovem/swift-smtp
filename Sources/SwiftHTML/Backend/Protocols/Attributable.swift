//
//  Attributable.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public protocol Attributable: HTMLNode {
    
    var attributes: Attributes { get set }
}

public extension Attributable {
    
    func attr(_ key: String, _ value: String) -> Self {
        var copy = self
        copy.attributes[key] = value
        return copy
    }

    func role(_ role: Role) -> Self {
        attr("role", role.rawValue)
    }

    func id(_ value: String) -> Self {
        attr("id", value)
    }

    func `class`(_ value: String) -> Self {
        attr("class", value)
    }

    func style(_ css: CSS) -> Self {
        var copy = self
        copy.attributes["style"] = copy.attributes["style"].appendStyle(css.render())
        return copy
    }
}
