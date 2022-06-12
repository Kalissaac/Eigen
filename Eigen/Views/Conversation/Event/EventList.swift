//
// EventList.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK
import CachedAsyncImage

struct MessageEvent: Identifiable {
    var id: String
    var timestamp: UInt64
    var sender: String
    var content: String
    var roomId: String
    var type: MessageEventType
}

enum MessageEventType {
    case text
    case image
    case file
}

struct EventList: View {
    @Binding var events: [MXEvent]
    @Binding var shouldLoadMore: Bool

    var body: some View {
        InfiniteList(events, hasReachedTop: $shouldLoadMore) { event in
            EventView(event: event)
        }
    }
}

struct EventView: View {
    @EnvironmentObject var matrix: MatrixModel
    var event: MXEvent

    var body: some View {
        switch event.eventType {
        case .roomMessage:
            let message = MessageEvent(
                id: event.eventId,
                timestamp: event.originServerTs,
                sender: event.sender,
                content: event.content[kMXMessageBodyKey] as? String ?? "(unknown content)",
                roomId: event.roomId,
                type: .text
            )
            if (event.content[kMXMessageTypeKey] as? String ?? "") == kMXMessageTypeImage {
                let mediaLoader = event.isEncrypted ? (
                    matrix.session.mediaManager.downloadEncryptedMedia(fromMatrixContentFile: event.getEncryptedContentFiles()[0], mimeType: "image/png", inFolder: nil)
                ) : (
                    matrix.session.mediaManager.downloadMedia(fromMatrixContentURI: event.getMediaURLs()[0], withType: nil, inFolder: nil)
                )

                if mediaLoader != nil {
                    Text(String(mediaLoader!.state.rawValue))
                    Text(mediaLoader!.downloadOutputFilePath)
                        .textSelection(.enabled)
                    if let image = MXMediaManager.loadThroughCache(withFilePath: mediaLoader!.downloadOutputFilePath) {
                        Image(nsImage: image)
                    }
//                    CachedAsyncImage(url: URL(string: mediaLoader.downloadOutputFilePath))
//                        .frame(width: 512, height: 256, alignment: .center)
//                        .scaleEffect(x: 1, y: -1, anchor: .center)
//                        .background(Color.gray)
                }
            }
            MessageEventView(message: message)
                .id(message.id)
        case .roomMember:
            if matrix.showRoomMemberEvents {
                MemberEventView(event: event)
            }
        default:
            Text(event.content["body"] as? String ?? "(unknown event)")
                .font(.caption)
        }
    }
}

//struct EventList_Previews: PreviewProvider {
//    static var previews: some View {
//        EventList(events: [])
//    }
//}
