//
// ConversationDetail.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK

enum MessageLoadStatus {
    case done
    case inProgress
    case error
}

struct ConversationDetail: View {
    @EnvironmentObject var matrix: MatrixModel

    var channel: MXRoom
    @State private var messageInputText = ""
    @State private var events: [MXEvent] = []
    @State private var roomTimeline: MXEventTimeline?
    @State private var messageLoadStatus: MessageLoadStatus = .inProgress

    init(channel: MXRoom) {
        self.channel = channel
    }
    
    var body: some View {
        VStack {
            EventList(events: $events)
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
        
        .onAppear(perform: loadInitialMessages)
        .onDisappear {
            roomTimeline?.removeAllListeners()
            // record last visited room time
        }
    }
    
    func loadInitialMessages() {
        guard roomTimeline == nil else { return }
        channel.liveTimeline { _timeline in
            guard let timeline: MXEventTimeline = _timeline else { return }
            roomTimeline = timeline

            _ = timeline.listenToEvents([.roomMessage, .roomMember, .reaction, .receipt, .typing], { event, _, _ in
                if events.first != nil && events.first!.originServerTs > event.originServerTs {
                    // Older event, insert at back
                    events.append(event)
                    events.sort(by: >)
                } else {
                    // Recent event, insert at front
                    events.insert(event, at: 0)
                }
            })
    
            timeline.resetPagination()
            timeline.paginate(100, direction: .backwards, onlyFromStore: false, completion: { response in
                guard response.value != nil else { return }
                messageLoadStatus = .done
            })
        }
    }

    func loadMoreMessages(withAmount amount: UInt = 50) {
        guard messageLoadStatus != .inProgress else { return }
        messageLoadStatus = .inProgress
        roomTimeline?.paginate(amount, direction: .backwards, onlyFromStore: false) { response in
            guard response.value != nil else { return }
            messageLoadStatus = .done
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
