//
//  HTMLDocument.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct HTMLDocument: HTMLNode, Attributable {
    
    public private(set) var languageCode: String
    
    public private(set) var body: Body
    public let head: Head?
    
    public var attributes: Attributes {
        get { body.attributes }
        set { body.attributes = newValue }
    }

    public init(
        languageCode: String = "en",
        @BodyBuilder body: () -> [BodyNode],
        @HeadBuilder head: () -> [HeadNode]
    ) {
        self.languageCode = languageCode
        self.body = Body(body())
        self.head = Head(head())
    }

    public init(
        languageCode: String = "en",
        @BodyBuilder body: () -> Body
    ) {
        self.languageCode = languageCode
        self.body = body()
        self.head = nil
    }

    public func render(into output: inout String, indent: Int) {
        output += "<!doctype html>\n"
        let indentValue = String.indentation(indent)
        let attrs = Attributes(["lang": languageCode]).render()
        output += "\(indentValue)<html\(attrs)>\n"

        var children: [HTMLNode] = [body]
        if let head {
            children.insert(head, at: 0)
        }
        
        for child in children {
            child.render(into: &output, indent: indent + 1)
        }
        output += "\(indentValue)</html>\n"
    }
}

public extension HTMLDocument {
    
    func language(_ languageCode: String) -> HTMLDocument {
        var copy = self
        copy.languageCode = languageCode
        return copy
    }
}
