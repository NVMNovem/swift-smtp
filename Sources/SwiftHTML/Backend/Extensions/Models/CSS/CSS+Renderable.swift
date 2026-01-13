//
//  CSS+Renderable.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 13/01/2026.
//

extension CSS: Renderable {
    
    internal func render() -> String {
        guard !styles.isEmpty else { return "" }
        
        let styles = styles.sorted(by: { $0.key < $1.key })
        let rendered = styles
            .map { $0.css }
            .joined(separator: "; ")
        
        return rendered
    }
}
