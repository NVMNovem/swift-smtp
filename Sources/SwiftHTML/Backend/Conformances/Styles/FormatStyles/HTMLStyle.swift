//
//  QuantityStyle.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 09/01/2026.
//

import Foundation

internal struct HTMLStyle: FormatStyle {
    
    func format(_ value: Int) -> String {
        return value.formatted(.number
            .grouping(.never)
        )
    }
}

extension FormatStyle where Self == HTMLStyle {
    
    internal static var html: Self {
        HTMLStyle()
    }
}
