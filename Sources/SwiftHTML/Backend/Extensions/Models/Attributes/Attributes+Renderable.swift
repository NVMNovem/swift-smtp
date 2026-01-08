//
//  Attributes+Renderable.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

extension Attributes: Renderable {
    
    internal func render() -> String {
        guard !self.isEmpty else { return "" }
        
        let keys = self.keys.sorted()
        let rendered = keys
            .map { key in
                let value = (self[key] ?? "").escapeHTML()
                return "\(key)=\"\(value)\""
            }
            .joined(separator: " ")
        
        return " " + rendered
    }
}
