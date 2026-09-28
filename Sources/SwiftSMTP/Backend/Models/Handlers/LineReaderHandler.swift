//
//  LineReaderHandler.swift
//  SwiftSMTP
//
//  Created by Damian Van de Kauter on 27/11/2025.
//

import NIO

internal final class LineReaderHandler: ChannelInboundHandler {

    typealias InboundIn = ByteBuffer

    internal enum Event: Sendable {
        case line(String)
        case failed(Swift.Error)
        case closed
    }

    // An AsyncStream preserves the order in which NIO delivers events,
    // so lines and connection loss are always observed in sequence.
    private let events: AsyncStream<Event>.Continuation

    internal init(events: AsyncStream<Event>.Continuation) {
        self.events = events
    }

    internal func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var buffer = self.unwrapInboundIn(data)
        if let line = buffer.readString(length: buffer.readableBytes) {
            events.yield(.line(line))
        }
    }

    internal func errorCaught(context: ChannelHandlerContext, error: Swift.Error) {
        events.yield(.failed(error))
        context.close(promise: nil)
    }

    internal func channelInactive(context: ChannelHandlerContext) {
        events.yield(.closed)
        events.finish()
        context.fireChannelInactive()
    }
}

extension LineReaderHandler: @unchecked Sendable {}
