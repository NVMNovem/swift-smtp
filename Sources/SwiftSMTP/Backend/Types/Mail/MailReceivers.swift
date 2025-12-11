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
        
        var all: [Contact] {
            switch self {
            case .single(let contact): [contact]
            case .multiple(let contacts): contacts
            }
        }
    }
}

extension Mail.Receivers: Sendable {}
