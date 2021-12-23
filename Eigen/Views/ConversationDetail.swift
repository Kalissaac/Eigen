//
// ConversationDetail.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK

struct MessageEvent: Identifiable {
    var id: String
    var timestamp: UInt64
    var sender: String
    var content: String
}

struct ConversationDetail: View {
    @EnvironmentObject var matrix: MatrixModel

    var channel: MXRoom
    @State private var messageInputText = ""
    @State private var events: Set<MXEvent> = Set()
    private var messages: Binding<[MessageEvent]> { Binding (
        get: {
            var messages = events.filter { event in
                event.eventType == .roomMessage
            }.map { event in
                MessageEvent(id: event.eventId,
                             timestamp: event.originServerTs,
                             sender: event.sender,
                             content: event.content["body"] as! String
                )
            }
            messages.sort { a, b in
                    a.timestamp < b.timestamp
                }
            return messages
        },
        set: { _ in }
    )}
    private var roomTimeline: MXEventTimeline?
    
    init(channel: MXRoom) {
        self.channel = channel
    }
    
    var body: some View {
        VStack {
            Group {
                Text("Number of events: \(events.count)")
                Text("Conversation ID: \(channel.roomId)")
            }
            
            List(messages) { $message in
                Text("\(message.sender): \(message.content)")
            }
            
            Spacer()
            
            HStack {
                TextField("Send message", text: $messageInputText)
                    .textFieldStyle(.roundedBorder)
                    .shadow(radius: 1)
                    .onSubmit {
                        matrix.session.matrixRestClient.sendTextMessage(toRoom: channel.roomId, text: messageInputText)
                        { response in
                            messageInputText = ""
                        }
                    }
                Button(action: { print("attachment") }) {
                    Image(systemName: "paperclip")
                }.buttonStyle(.borderless)
            }
            .padding()
        }
        .navigationTitle(channel.summary.displayname)
        
        .onAppear(perform: loadMessages)
        .onDisappear {
            roomTimeline?.removeAllListeners()
        }
    }
    
    func loadMessages() {
        channel.liveTimeline { _timeline in
            let timeline: MXEventTimeline = _timeline!
            
            _ = timeline.listenToEvents([MXEventType.roomMessage], { event, _, _ in
                events.insert(event)
            })
    
            timeline.resetPagination()
            timeline.paginate(100, direction: .backwards, onlyFromStore: false, completion: { _ in })
        }
    }
}

//struct ConversationDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        ConversationDetail(channel: MXRoom())
//    }
//}
