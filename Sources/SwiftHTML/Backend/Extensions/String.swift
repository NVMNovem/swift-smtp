//
//  String.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

import Foundation

internal extension String {
    
    static func indentation(_ indent: Int) -> String {
        String(repeating: "  ", count: indent)
    }
}

internal extension String {
    
    func appendStyle(_ newStyle: String) -> String {
        let existingStyle = self
        guard !existingStyle.isEmpty else { return newStyle }
        
        if existingStyle.hasSuffix(";") {
            return "\(existingStyle) \(newStyle)"
        }
        
        return "\(existingStyle); \(newStyle)"
    }
    
    mutating func appendedStyle(_ newStyle: String) {
        self = self.appendStyle(newStyle)
    }
    
    func escapeHTML() -> String {
        var escaped = ""
        escaped.reserveCapacity(self.count)
        for char in self {
            switch char {
            case "&": escaped += "&amp;"
            case "<": escaped += "&lt;"
            case ">": escaped += "&gt;"
            case "\"": escaped += "&quot;"
            case "'": escaped += "&#39;"
            default: escaped.append(char)
            }
        }
        return escaped
    }
    
    mutating func escapedHTML() {
        self = self.escapeHTML()
    }
}

internal extension Optional where Wrapped == String {
    
    func appendStyle(_ newStyle: String) -> String {
        guard let existingStyle = self, !existingStyle.isEmpty else { return newStyle }
        return existingStyle.appendStyle(newStyle)
    }
    
    mutating func appendedStyle(_ newStyle: String) {
        guard let existingStyle = self, !existingStyle.isEmpty else { return }
        self = self.appendStyle(newStyle)
    }
}
