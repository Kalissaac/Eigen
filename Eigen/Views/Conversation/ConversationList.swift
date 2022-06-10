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

                MXCrypto.check(withMatrixSession: matrix.session) { crypto in
                    if crypto == nil {
                        matrix.session.enableCrypto(true) { _ in
                            matrix.session.crypto.start { } failure: { e in
                                print(e!)
                            }
                        }
                    } else {
                        crypto!.start { } failure: { e in
                            print(e!)
                        }
                    }
                }
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
            room.isDirect == false &&
            room.summary.roomType == .room
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
            VStack(spacing: 0) {
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
//                    NavigationLink(destination: PreferencesView(), tag: "preferences", selection: $activeConversation) {
//                        Image(systemName: "gear")
//                        Text("Preferences")
//                    }

                    Section(header: Text("Conversations")) {
                        ForEach(directMessages, id: \.self) { channel in
                            NavigationLink(
                                destination: ConversationDetail(channel: channel),
                                tag: channel.roomId,
                                selection: $activeConversation) {
                                    HStack {
                                        Image(systemName: "person")
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
                    .padding(.bottom, 0)
                NavigationLink(destination: PreferencesView(), tag: "preferences", selection: $activeConversation) {
                    UserAvatarView(user: matrix.session.myUser, height: 18.0, width: 18.0)
                        .environmentObject(RoomData())
                    let usernamePortion = matrix.session.myUser?.userId.split(separator: ":")[0]
                    let homeserverPortion = matrix.session.myUser?.userId.split(separator: ":")[1]
                    HStack(spacing: 0) {
                        Text(usernamePortion ?? "")
                            .fontWeight(.medium)
                        Text(":" + (homeserverPortion ?? ""))
                            .fontWeight(.light)
                    }
                }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.vertical, 12.0)
                    .frame(maxWidth: .infinity)
                    .background(activeConversation == "preferences" ? Color.accentColor : .clear, ignoresSafeAreaEdges: .all)
                    .foregroundColor(activeConversation == "preferences" ? Color("AccentColorInvert") : .accentColor)
            }
        }
        
        .toolbar {
            if activeConversation?.contains(":") == true {
                Button(action: { showDetailInfo = true }) {
                    Label("About this conversation", systemImage: "info.circle")
                }
                .popover(isPresented: $showDetailInfo, arrowEdge: .bottom) {
                    ConversationDetailInfo(channel: matrix.session.room(withRoomId: activeConversation))
                }
            } else {
                NavigationLink(destination: PreferencesView()) {
                    Label("About me", systemImage: "person.crop.circle")
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
