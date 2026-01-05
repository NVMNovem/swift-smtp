//
//  MailAttachment.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 05/01/2026.
//

import Foundation

public extension Mail {
    
    struct Attachment {
        
        public let filename: String
        public let mimeType: String
        public let data: Data

        public init(filename: String, mimeType: String, data: Data) {
            self.filename = filename
            self.mimeType = mimeType
            self.data = data
        }
    }
    
    struct InlineImage {
        
        public let contentID: String
        public let filename: String
        public let mimeType: String
        public let data: Data

        public init(contentID: String, filename: String, mimeType: String, data: Data) {
            self.contentID = contentID
            self.filename = filename
            self.mimeType = mimeType
            self.data = data
        }
    }
}

extension Mail.Attachment: Sendable {}

extension Mail.Attachment: Equatable {}

extension Mail.InlineImage: Sendable {}

extension Mail.InlineImage: Equatable {}
