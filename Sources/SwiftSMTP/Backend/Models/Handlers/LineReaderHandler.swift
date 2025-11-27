//
//  LineReaderHandler.swift
//  SwiftSMTP
//
//  Created by Damian Van de Kauter on 27/11/2025.
//

import NIO

internal final class LineReaderHandler: ChannelInboundHandler {
    
    typealias InboundIn = ByteBuffer
    private var onLine: (String) -> Void
    
    internal init(onLine: @escaping (String) -> Void) {
        self.onLine = onLine
    }
    
    internal func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var buffer = self.unwrapInboundIn(data)
        if let line = buffer.readString(length: buffer.readableBytes) {
            onLine(line)
        }
    }
}

extension LineReaderHandler: @unchecked Sendable {}
