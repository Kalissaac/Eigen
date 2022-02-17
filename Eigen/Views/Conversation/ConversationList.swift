//
// ConversationList.swift
// Eigen
//

import SwiftUI
import MatrixSDK

struct ConversationList: View {
    @EnvironmentObject var matrix: MatrixModel

    @State var activeConversation: String? = "recents"
    @State var searchText: String?
    @State private var directMessages: [MXRoom] = []
    @State private var channels: [MXRoom] = []
    @State private var showDetailInfo = false
        
    func fetch() {
        matrix.session.setStore(matrix.store) { response in
            guard response.isSuccess else { return }
            updateRoomStates()

            matrix.session.start { response in
                guard response.isSuccess else { return }
                updateRoomStates()
            }
        }
    }

    func updateRoomStates() {
        let allRooms = matrix.session.rooms

        directMessages = allRooms.filter({ room in
            room.isDirect == true
        }).sorted(by: { roomA, roomB in
            return roomA.summary.lastMessage.originServerTs > roomB.summary.lastMessage.originServerTs
        })

        channels = allRooms.filter({ room in
            room.isDirect == false
        }).sorted(by: { roomA, roomB in
            if roomA.summary.hasAnyHighlight && !roomB.summary.hasAnyHighlight {
                return true
            } else if !roomA.summary.hasAnyHighlight && roomB.summary.hasAnyHighlight {
                return false
            }
            if roomA.summary.hasAnyUnread && !roomB.summary.hasAnyUnread {
                return true
            } else if !roomA.summary.hasAnyUnread && roomB.summary.hasAnyUnread {
                return false
            }
            return roomA.summary.displayname < roomB.summary.displayname
        })
    }
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: SearchResults(), tag: "search", selection: $activeConversation) {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                NavigationLink(destination: RecentsList(), tag: "recents", selection: $activeConversation) {
                    Image(systemName: "clock")
                    Text("Recents")
                }
                NavigationLink(destination: NotificationList(), tag: "notifications", selection: $activeConversation) {
                    Image(systemName: "bell")
                    Text("Inbox")
                }
                NavigationLink(destination: PreferencesView(), tag: "preferences", selection: $activeConversation) {
                    Image(systemName: "gear")
                    Text("Preferences")
                }
                
                Section(header: Text("Conversations")) {
                    ForEach(directMessages, id: \.self) { channel in
                        NavigationLink(
                            destination: ConversationDetail(channel: channel),
                            tag: channel.roomId,
                            selection: $activeConversation) {
                                Image(systemName: "person")
                                Text(channel.summary.displayname)
                        }
                    }
                }
                
                Section(header: Text("Channels")) {
                    ForEach(channels, id: \.self) { channel in
                        NavigationLink(
                            destination: ConversationDetail(channel: channel),
                            tag: channel.roomId,
                            selection: $activeConversation) {
                                HStack {
                                    Image(systemName: "number")
                                    Text(channel.summary?.displayname ?? channel.roomId)
                                    if channel.summary?.hasAnyUnread == true {
                                        Spacer()
                                        Circle()
                                            .frame(width: 8, height: 8)
                                            .foregroundColor(channel.summary?.hasAnyHighlight == true ? .red : .primary)
                                    }
                                }
                        }
                    }
                }
            }
            .listStyle(.sidebar)
        }
        
        .toolbar {
            if activeConversation?.contains(":") == true {
                Button(action: { showDetailInfo = true }) {
                    Label("About this conversation", systemImage: "info.circle")
                }
                .popover(isPresented: $showDetailInfo, arrowEdge: .bottom) {
                    ConversationDetailInfo(channel: matrix.session.rooms.first(where: { room in
                        room.roomId == activeConversation
                    })!)
                }
            } else {
                Button(action: { showDetailInfo = true }) {
                    Label("About me", systemImage: "person.crop.circle")
                }
                .popover(isPresented: $showDetailInfo, arrowEdge: .bottom) {
                    ProfileView()
                }
            }
        }
        
        .onAppear(perform: fetch)
    }
}

struct ConversationList_Previews: PreviewProvider {
    static var previews: some View {
        ConversationList()
    }
}
