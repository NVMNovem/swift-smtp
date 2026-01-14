//
//  Attributes+Renderable.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

extension Attributes: Renderable {
    
    internal func render() -> String {
        guard !self.isEmpty else { return "" }
        
        let attributes = sort ? self.attributes.sorted(by: { $0.name < $1.name }) : self.attributes
        let rendered = attributes
            .map { "\($0.name)=\"\($0.value.escapeHTML())\"" }
            .joined(separator: " ")
        
        return " " + rendered
    }
}
