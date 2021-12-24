//
// ConversationDetail.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK
import Combine

struct MessageEvent: Identifiable {
    var id: String
    var timestamp: UInt64
    var sender: String
    var content: String
    var roomId: String
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
                             content: event.content["body"] as! String,
                             roomId: event.roomId
                )
            }
            messages.sort { a, b in
                    a.timestamp < b.timestamp
                }
            return messages
        },
        set: { _ in }
    )}
    @State private var roomTimeline: MXEventTimeline?
    
    init(channel: MXRoom) {
        self.channel = channel
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    ForEach(messages) { $message in
                        ConversationMessage(message: message)
                            .id(message.id)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 2)
                    .onReceive(Just(messages), perform: { messages in
                        if let lastMessage = messages.last {
                            scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    })
                }
                .padding(.top, 8)
            }
                        
            HStack {
                TextField("Send message", text: $messageInputText)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        matrix.session.matrixRestClient.sendTextMessage(toRoom: channel.roomId, text: messageInputText)
                        { response in
                            messageInputText = ""
                        }
                    }
                Button(action: selectAttachment) {
                    Image(systemName: "paperclip")
                }.buttonStyle(.borderless)
            }
            .padding(.horizontal, 12)
            .padding(.top, 4)
            .padding(.bottom, 12)
        }
        .navigationTitle(channel.summary.displayname)
        
        .onAppear(perform: loadMessages)
        .onDisappear {
            roomTimeline?.removeAllListeners()
        }
    }
    
    func loadMessages() {
        if roomTimeline != nil { return }
        channel.liveTimeline { _timeline in
            guard let timeline: MXEventTimeline = _timeline else { return }
            roomTimeline = timeline
            
            _ = timeline.listenToEvents([MXEventType.roomMessage], { event, _, _ in
                events.insert(event)
            })
    
            timeline.resetPagination()
            timeline.paginate(100, direction: .backwards, onlyFromStore: false, completion: { _ in })
        }
    }
    
    func selectAttachment() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if panel.runModal() == .OK {
            guard let fileURL = panel.url else { return }
            guard let fileContents = FileManager.default.contents(atPath: fileURL.path) else { return }
            
            matrix.session.matrixRestClient.uploadContent(
                fileContents,
                filename: fileURL.lastPathComponent,
                mimeType: fileURL.mimeType(),
                timeout: 60)
            { progress in
                guard progress.isSuccess else { return }
                
                var messageType: MXMessageType
                if fileURL.containsImage {
                    messageType = .image
                } else if fileURL.containsAudio {
                    messageType = .audio
                } else if fileURL.containsVideo {
                    messageType = .video
                } else {
                    messageType = .file
                }
                
                matrix.session.matrixRestClient.sendMessage(
                    toRoom: channel.roomId,
                    messageType: messageType,
                    content: [
                        "body": fileURL.lastPathComponent,
                        "url": progress.value!.absoluteString
                    ])
                { _ in }
            }
        }
    }
}

//struct ConversationDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        ConversationDetail(channel: MXRoom())
//    }
//}
