//
// RecentsList.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK

struct RecentsList: View {
    @EnvironmentObject private var matrix: MatrixModel

    @Binding var activeConversation: String?

    var body: some View {
        VStack {
            List(matrix.session.rooms.sorted(by: { a, b in
                a.compareLastMessageEventOriginServerTs(b) == .orderedAscending
            }).prefix(10), id: \.roomId) { room in
                Button {
                    activeConversation = room.id
                } label: {
                    VStack(alignment: .leading) {
                        HStack {
                            AvatarView(url: room.summary.avatar, height: 28.0, width: 28.0)
                            Text(room.summary.displayname)
                                .fontWeight(.semibold)
                                .padding(.leading, 6)
                        }
                        HStack {
                            Text("last event at \((room.summary?.lastMessage.originServerTs ?? 0).toString())")
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(.vertical, 8)
            }
        }
            .navigationTitle("Recent conversations")
    }
}

struct RecentsList_Previews: PreviewProvider {
    static var previews: some View {
        RecentsList(activeConversation: .constant("recents"))
    }
}
