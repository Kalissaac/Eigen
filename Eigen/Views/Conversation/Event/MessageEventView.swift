//
// MessageEventView.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK
import CachedAsyncImage

struct MessageEventView: View {
    @EnvironmentObject private var matrix: MatrixModel

    @State var message: MessageEvent

    var body: some View {
        EventView(event: message.rawEvent) { user in
            VStack {
                HStack {
                    Text(user.wrappedValue?.displayname ?? message.sender)
                        .fontWeight(.semibold)
                    Text(message.timestamp.toString())
                        .foregroundColor(.secondary)
                        .fontWeight(.light)
                        .padding(.leading, 2)
                }
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(LocalizedStringKey(message.content))
                    .foregroundColor(.secondary)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 12) {
                    ForEach(message.reactions) { reaction in
                        Button {
                            react(toReaction: reaction)
                        } label: {
                            Text(String(reaction.count))
                                .foregroundColor(reaction.myUserHasReacted ? .primary : .secondary)
                            Text(reaction.reaction)
                                .dynamicTypeSize(.xSmall)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
            .onAppear(perform: fetchReactions)
    }

    func fetchReactions() {
        guard let messageEventId = message.rawEvent.eventId else { return }
        guard let messageRoomId = message.rawEvent.roomId else { return }
        matrix.session.aggregations.reactionsEvents(forEvent: messageEventId, inRoom: messageRoomId, from: nil, limit: 999) { response in
            guard let reactionCounts = matrix.session.aggregations.aggregatedReactions(onEvent: messageEventId, inRoom: messageRoomId)?.reactions else { return }
            for reactionCount in reactionCounts {
                if let reactionIndex = message.reactions.firstIndex(where: { $0.reaction == reactionCount.reaction }) {
                    message.reactions[reactionIndex].count += 1
                    if reactionCount.myUserHasReacted {
                        message.reactions[reactionIndex].myUserHasReacted = true
                    }
                } else {
                    message.reactions.append(MessageReaction(id: reactionCount.reaction, reaction: reactionCount.reaction, count: reactionCount.count, myUserHasReacted: reactionCount.myUserHasReacted))
                }
            }
            message.reactions.sort { a, b in
                a.count > b.count
            }
        } failure: { err in
            print(err)
        }
    }

    func react(toReaction reaction: MessageReaction) {
        if reaction.myUserHasReacted {
            matrix.session.aggregations.removeReaction(reaction.reaction, forEvent: message.rawEvent.eventId, inRoom: message.rawEvent.roomId) {
                fetchReactions()
            } failure: { err in
                print(err)
            }
        } else {
            matrix.session.aggregations.addReaction(reaction.reaction, forEvent: message.rawEvent.eventId, inRoom: message.rawEvent.roomId) {
                fetchReactions()
            } failure: { err in
                print(err)
            }
        }
    }
}

struct MessageEventView_Previews: PreviewProvider {
    static var previews: some View {
        MessageEventView(message: MessageEvent(id: "", timestamp: 0, sender: "", content: "Hello world!", roomId: "", type: .text, reactions: [], rawEvent: MXEvent()))
    }
}
