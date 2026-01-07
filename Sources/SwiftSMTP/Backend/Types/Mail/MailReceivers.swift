//
//  Receivers.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 11/12/2025.
//

public extension Mail {
    
    enum Receivers {
        
        case single(Contact)
        case multiple([Contact])
    }
}

extension Mail.Receivers: Sendable {}

extension Mail.Receivers: Equatable {}

public extension Mail.Receivers {
    
    var all: [Mail.Contact] {
        switch self {
        case .single(let contact): [contact]
        case .multiple(let contacts): contacts
        }
    }
}

public extension Optional where Wrapped == Mail.Receivers {
    
    var all: [Mail.Contact] {
        switch self {
        case .single(let contact): [contact]
        case .multiple(let contacts): contacts
        case .none: []
        }
    }
}

// MARK: - Internal Formatting
internal extension Mail.Receivers {
    
    func formatted() -> String {
        all.map { $0.formatted() }.joined(separator: ", ")
    }
}
