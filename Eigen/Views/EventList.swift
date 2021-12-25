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
}

struct EventList: View {
    @Binding var events: [MXEvent]

    var body: some View {
        List($events, id: \.eventId) { $event in
            switch event.eventType {
            case .roomMessage:
                let message = MessageEvent(
                    id: event.eventId,
                    timestamp: event.originServerTs,
                    sender: event.sender,
                    content: event.content["body"] as? String ?? "(unknown content)",
                    roomId: event.roomId
                )
                MessageEventView(message: message)
                    .id(message.id)
                    .scaleEffect(x: 1, y: -1, anchor: .center)
            case .roomMember:
                MemberEventView(event: event)
                    .scaleEffect(x: 1, y: -1, anchor: .center)
            default:
                Text(event.content["body"] as? String ?? "(unknown event)")
                    .font(.caption)
                    .scaleEffect(x: 1, y: -1, anchor: .center)
            }
        }
        .scaleEffect(x: 1, y: -1, anchor: .center)
    }
}

//struct EventList_Previews: PreviewProvider {
//    static var previews: some View {
//        EventList(events: [])
//    }
//}
