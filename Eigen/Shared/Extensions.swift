//
// Extensions.swift
// Eigen
//
        

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import MatrixSDK

extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}

extension URL {
    func mimeType() -> String {
        let pathExtension = self.pathExtension
        if let type = UTType(filenameExtension: pathExtension) {
            if let mimetype = type.preferredMIMEType {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    
    var containsImage: Bool {
        let mimeType = self.mimeType()
        if let type = UTType(mimeType: mimeType) {
            return type.conforms(to: .image)
        }
        return false
    }
    
    var containsAudio: Bool {
        let mimeType = self.mimeType()
        if let type = UTType(mimeType: mimeType) {
            return type.conforms(to: .audio)
        }
        return false
    }
    
    var containsVideo: Bool {
        let mimeType = self.mimeType()
        if let type = UTType(mimeType: mimeType) {
            return type.conforms(to: .video) || type.conforms(to: .movie)
        }
        return false
    }
}

extension MXEvent: Identifiable {
    public var id: String { eventId ?? String(originServerTs) }
}

extension MXRoom: Identifiable {
    public var id: String { roomId }
}

extension UInt64 {
    func toString() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self / 1000))
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        if Calendar.autoupdatingCurrent.isDateInToday(date) {
            formatter.dateStyle = .none
            return formatter.string(from: date)
        }
        return formatter.string(from: date)
    }
}
