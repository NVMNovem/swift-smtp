//
//  Markdown+Renderable.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

extension Markdown: Renderable {
    
    internal func render() -> String {
        var output = ""
        var index = value.startIndex
        
        while index < value.endIndex {
            let current = value[index]
            
            if current == "\n" {
                output += "<br>"
                advance()
                continue
            }
            
            if current == "`" {
                let next = value.index(after: index)
                if let end = value[next...].firstIndex(of: "`") {
                    let content = String(value[next..<end])
                    let code = content.escapeHTML()
                    output += "<code style=\"font-family: monospace;\">\(code)</code>"
                    index = value.index(after: end)
                    continue
                }
            }
            
            if current == "*" {
                let next = value.index(after: index)
                if next < value.endIndex, value[next] == "*" {
                    let start = value.index(after: next)
                    if let end = value[start...].firstIndex(of: "*") {
                        let endNext = value.index(after: end)
                        if endNext < value.endIndex, value[endNext] == "*" {
                            let content = String(value[start..<end])
                            let strong = content.escapeHTML()
                            output += "<strong>\(strong)</strong>"
                            index = value.index(after: endNext)
                            continue
                        }
                    }
                }
            }
            
            output += String(current).escapeHTML()
            advance()
        }
        
        return output
        
        func advance(_ count: Int = 1) {
            index = value.index(index, offsetBy: count)
        }
    }
}
