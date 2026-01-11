//
//  Attributes.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

import Foundation

public struct Attributes: ExpressibleByDictionaryLiteral {
    
    internal private(set) var attributes: [Attribute]
    internal private(set) var sort: Bool = true
    
    public struct Attribute: Hashable, Sendable {
        let name: String
        let value: String
    }
    
    public init(_ value: [String: String]) {
        self.attributes = value.reduce(into: []) { $0.append(Attribute(name: $1.key, value: $1.value)) }
    }
    
    public init(dictionaryLiteral elements: (String, String)...) {
        self.attributes = elements.reduce(into: []) { $0.append(Attribute(name: $1.0, value: $1.1)) }
    }
}

extension Attributes: Sendable {}

extension Attributes: Collection, RangeReplaceableCollection {
    
    public init() {
        self.attributes = []
    }
    
    public var startIndex: Int { attributes.startIndex }
    public var endIndex: Int { attributes.endIndex }
    
    public func index(after i: Int) -> Int {
        attributes.index(after: i)
    }
    
    public subscript(position: Int) -> Attribute {
        attributes[position]
    }
    
    public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, C.Element == Attribute {
        attributes.replaceSubrange(subrange, with: newElements)
    }
}

public extension Attributes {
    
    subscript(key: String) -> String? {
        get {
            attributes.first(where: { $0.name == key })?.value
        }
        set {
            attributes.removeAll(where: { $0.name == key })
            if let newValue {
                attributes.append(Attribute(name: key, value: newValue))
            }
        }
    }
    
    var keys: [String] { attributes.map(\.name) }
    var isEmpty: Bool { attributes.isEmpty }
}


public extension Attributes {
    
    static let empty: Attributes = [:]
}

public extension Attributes {
    
    func disableSorting() -> Attributes {
        var copy = self
        copy.sort = false
        return copy
    }
}
