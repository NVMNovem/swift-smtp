//
//  Attributes.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

import Foundation

public struct Attributes: ExpressibleByDictionaryLiteral {
    
    internal private(set) var value: [String: String]
    
    public init(_ value: [String: String]) {
        self.value = value
    }
    
    public init(dictionaryLiteral elements: (String, String)...) {
        var dict: [String: String] = [:]
        
        for (key, value) in elements {
            dict[key] = value
        }
        
        self.value = elements.reduce(into: [:]) { $0[$1.0] = $1.1 }
    }
}

extension Attributes: Sendable {}

public extension Attributes {
    
    subscript(key: String) -> String? {
        get { value[key] }
        set { value[key] = newValue }
    }
    
    var keys: Dictionary<String, String>.Keys { value.keys }
    var isEmpty: Bool { value.isEmpty }
}

public extension Attributes {
    
    static let empty: Attributes = [:]
}
