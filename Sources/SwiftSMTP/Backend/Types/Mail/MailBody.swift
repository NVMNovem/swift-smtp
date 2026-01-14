//
//  Body.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 05/01/2026.
//

public extension Mail {
    
    enum Body {
        
        case plain(String)
        case html(String)
        case alternative(plain: String, html: String)
    }
}

extension Mail.Body: Sendable, Equatable {}

public extension Mail.Body {
    
    /// Plain-text representation used for text-only parts or fallbacks.
    var plainText: String {
        switch self {
        case .plain(let text): text
        case .html(let html): html
        case .alternative(let plain, _): plain
        }
    }
    
    /// HTML representation when available.
    var htmlText: String? {
        switch self {
        case .plain: nil
        case .html(let html): html
        case .alternative(_, let html): html
        }
    }
}
