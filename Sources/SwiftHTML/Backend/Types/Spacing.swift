//
//  Spacing.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public enum Spacing: Int {
    
    case xSmall = 4
    case small = 8
    case medium = 12
    case large = 16
    case xLarge = 24
    case xxLarge = 32

    var px: Int {
        rawValue
    }
}
