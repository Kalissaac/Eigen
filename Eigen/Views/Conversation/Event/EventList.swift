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
    var reactions: [MessageReaction]
    var rawEvent: MXEvent
}

enum MessageEventType {
    case text
    case image
    case file
}

struct MessageReaction: Identifiable {
    var id: String
    var reaction: String
    var count: UInt
    var myUserHasReacted: Bool
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
                type: .text,
                reactions: [],
                rawEvent: event
            )
            if (event.content[kMXMessageTypeKey] as? String ?? "") == kMXMessageTypeImage {
                MessageEventImageView(event: event)
                    .padding(.bottom, 8)
            }
            MessageEventView(message: message)
        case .reaction:
            // reactions are rendered in MessageEventView
            EmptyView()
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

struct EventList_Previews: PreviewProvider {
    static var previews: some View {
        EventList(events: .constant([]), shouldLoadMore: .constant(false))
    }
}
