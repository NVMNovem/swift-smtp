//
//  Duration.swift
//  SwiftSMTP
//
//  Created by Damian Van de Kauter on 28/09/2026.
//

internal extension Duration {

    var nanoseconds: Int64 {
        let (seconds, attoseconds) = components
        return seconds * 1_000_000_000 + attoseconds / 1_000_000_000
    }
}
