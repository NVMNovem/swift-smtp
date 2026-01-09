//
//  Frameable.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 09/01/2026.
//

import Foundation

internal protocol Frameable {
    
    var attributes: Attributes { get set }
}

extension Frameable {
    
    func frame(width: Int) -> Self {
        var copy = self
        copy.attributes["width"] = width.formatted(.html)
        return copy
    }
}
