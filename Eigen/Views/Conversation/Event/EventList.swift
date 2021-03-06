//
// EventList.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK

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
            EventListItem(event: event)
        }
    }
}

struct EventListItem: View {
    @EnvironmentObject private var matrix: MatrixModel
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
                MessageEventImageView(event: event)
            }
            MessageEventView(event: event, message: message)
        case .roomMember:
            if matrix.preferences.showRoomMemberEvents {
                MemberEventView(event: event)
            }
        case .callInvite:
            CallInviteEventView(event: event)
        case .callReject:
            CallRejectEventView(event: event)
        case .callHangup:
            CallHangupEventView(event: event)
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
