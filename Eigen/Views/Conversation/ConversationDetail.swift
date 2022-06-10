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

final class RoomData: ObservableObject {
    @Published var members = MXRoomMembers()
}

struct ConversationDetail: View {
    @EnvironmentObject var matrix: MatrixModel

    let channel: MXRoom
    @State private var messageInputText = ""
    @State private var events: [MXEvent] = []
    @State private var roomTimeline: MXEventTimeline?
    @State private var messageLoadStatus: MessageLoadStatus = .inProgress
    @StateObject var roomData = RoomData()

    init(channel: MXRoom) {
        self.channel = channel
    }
    
    var body: some View {
        VStack {
            EventList(events: $events)
                .environmentObject(roomData)
            HStack {
                TextField("Send message", text: $messageInputText)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        var echoEvent: MXEvent?
                        channel.sendTextMessage(messageInputText, localEcho: &echoEvent) { _ in }
                        if echoEvent != nil {
                            insertEvent(echoEvent!)
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
        .onDisappear(perform: roomTimeline?.removeAllListeners)
    }
    
    func loadInitialMessages() {
        channel.members { members in
            guard members != nil else { return }
            roomData.members = members!
        } lazyLoadedMembers: { members in
            guard members != nil else { return }
            roomData.members = members!
        } failure: { error in
            print(error!)
        }

        if channel.summary.isEncrypted {
            matrix.session.crypto.ensureEncryption(inRoom: channel.roomId) { }
            failure: { err in
                print(err as Any)
            }
        }

        guard roomTimeline == nil else { return }
        channel.liveTimeline { _timeline in
            guard let timeline: MXEventTimeline = _timeline else { return }
            roomTimeline = timeline

            matrix.session.crypto.resetReplayAttackCheck(inTimeline: timeline.timelineId)

            _ = timeline.listenToEvents([.roomMessage, .roomMember, .reaction, .receipt, .typing], { event, _, _ in
                matrix.session.crypto.resetReplayAttackCheck(inTimeline: timeline.timelineId)
                if event.isEncrypted {
                    matrix.session.crypto.decryptEvents([event], inTimeline: timeline.timelineId) { decryptedEvents in
                        guard decryptedEvents != nil else { return }
                        for e in decryptedEvents! {
                            event.setClearData(e)
                            if e.error == nil {
                                insertEvent(event)
                            } else {
                                print(e.error!)
                            }
                        }
                    }
                } else {
                    insertEvent(event)
                }
            })
    
            timeline.resetPagination()
            timeline.paginate(200, direction: .backwards, onlyFromStore: false, completion: { response in
                guard response.value != nil else { return }
                messageLoadStatus = .done
                channel.markAllAsRead()
                clearAllNotifications()
            })
        }
    }

    func insertEvent(_ event: MXEvent) {
        if let i = events.firstIndex(where: { e in e.eventId == event.eventId }) {
            events[i] = event
            return
        }
        if events.first != nil && events.first!.originServerTs > event.originServerTs {
            // Older event, insert at back
            events.append(event)
            events.sort(by: <)
        } else {
            // Recent event, insert at front
            events.insert(event, at: 0)

            if events.count > 1 {
                sendNotification(id: "RECIEVE \(event.eventId ?? "") FROM \(event.sender ?? "") IN \(channel.roomId ?? "")", title: event.sender ?? "New Message", body: event.content[kMXMessageBodyKey] as? String ?? "Message")
            }
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
            do {
                guard try fileURL.checkResourceIsReachable() else { return }
            } catch { return }

            var event: MXEvent?

            if fileURL.containsImage {
                let image = NSImage(byReferencing: fileURL)
                guard let fileContents = FileManager.default.contents(atPath: fileURL.path) else { return }
                channel.sendImage(fileContents, withImageSize: image.size, mimeType: fileURL.mimeType(), andThumbnail: NSImage(), threadId: channel.roomId, localEcho: &event)
                { _ in } failure: { e in
                    print(e!)
                }
            } else if fileURL.containsVideo {
                channel.sendVideo(localURL: fileURL, thumbnail: nil, threadId: nil, localEcho: &event) { _ in }
            } else if fileURL.containsAudio {
                channel.sendAudioFile(localURL: fileURL, mimeType: fileURL.mimeType(), threadId: nil, localEcho: &event) { _ in }
            } else {
                channel.sendFile(localURL: fileURL, mimeType: fileURL.mimeType(), localEcho: &event) { _ in }
            }

            if let e = event {
                insertEvent(e)
            }
        }
    }
}

//struct ConversationDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        ConversationDetail(channel: MXRoom())
//    }
//}
