//
// ConversationList.swift
// Eigen
//

import SwiftUI
import MatrixSDK

struct ConversationList: View {
    @EnvironmentObject private var matrix: MatrixModel

    @State private var activeConversation: String? = "loading"
    @State private var showAccountSwitcher = false
    @State private var searchText: String?
    @State private var directMessages: [MXRoom] = []
    @State private var channels: [MXRoom] = []

    func updateRoomStates() {
        let allRooms = matrix.session.rooms.filter { room in
            !room.summary.hiddenFromUser
        }

        directMessages = allRooms.filter({ room in
            room.isDirect
        }).sorted(by: { roomA, roomB in
            if matrix.preferences.prioritizeRoomsWithActivity {
                return roomA.summary.lastMessage.originServerTs > roomB.summary.lastMessage.originServerTs
            }

            return roomA.summary.displayname < roomB.summary.displayname
        })

        channels = allRooms.filter({ room in
            !room.isDirect &&
            room.summary.roomType == .room
        }).sorted(by: { roomA, roomB in
            if matrix.preferences.prioritizeRoomsWithActivity {
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
            }

            return roomA.summary.displayname < roomB.summary.displayname
        })
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if activeConversation == "loading" {
                    NavigationLink(destination: ProgressView(), tag: "loading", selection: $activeConversation) {}
                        .buttonStyle(.plain)
                } else {
                    List {
                        NavigationLink(destination: SearchResults(), tag: "search", selection: $activeConversation) {
                            Image(systemName: "magnifyingglass")
                            Text("Search")
                        }
                        NavigationLink(destination: RecentsList(activeConversation: $activeConversation), tag: "recents", selection: $activeConversation) {
                            Image(systemName: "clock")
                            Text("Recents")
                        }
                        NavigationLink(destination: NotificationList(), tag: "notifications", selection: $activeConversation) {
                            Image(systemName: "bell")
                            Text("Inbox")
                        }

                        Section(header: Text("People")) {
                            ForEach(directMessages, id: \.roomId) { channel in
                                RoomLink(room: channel, activeConversation: $activeConversation, icon: "person")
                            }
                        }

                        Section(header: Text("Rooms")) {
                            ForEach(channels, id: \.roomId) { channel in
                                RoomLink(room: channel, activeConversation: $activeConversation)
                            }
                        }
                    }
                        .listStyle(.sidebar)
                        .padding(.bottom, 0)
                    NavigationLink(destination: PreferencesView(), tag: "preferences", selection: $activeConversation) {
                        if let userIdSplit = matrix.session.myUser?.userId.split(separator: ":") {
                            let username = userIdSplit[0]
                            let homeserver = userIdSplit[1]
                            HStack {
                                UserAvatarView(user: .constant(matrix.session.myUser), height: 18, width: 18)
                                    .environmentObject(RoomData())
                                HStack(spacing: 0) {
                                    Text(username)
                                        .fontWeight(.medium)
                                    Text(":" + homeserver)
                                        .fontWeight(.light)
                                }
                            }
                            Button {
                                showAccountSwitcher = true
                            } label: {
                                Image(systemName: "chevron.up.chevron.down")
                            }
                                .buttonStyle(.plain)
                        }
                    }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(activeConversation == "preferences" ? Color.accentColor : .clear, ignoresSafeAreaEdges: .all)
                        .foregroundColor(activeConversation == "preferences" ? Color("AccentColorInvert") : .accentColor)
                        .disabled(matrix.session.myUser == nil)
                        .popover(isPresented: $showAccountSwitcher) {
                            VStack {
                                Spacer()
                                ForEach(MatrixModel.getAccounts(), id: \.["username"]) { account in
                                    let username = account["username"] ?? ""
                                    let usernameSplit = username.split(separator: ":")
                                    Button {
                                        guard username != matrix.session.myUserId else { return }
                                        activeConversation = "loading"
                                        matrix.switchSession(account: account)
                                    } label: {
                                        HStack {
                                            HStack {
                                                UserAvatarView(user: .constant(matrix.session.myUser), height: 18, width: 18)
                                                    .environmentObject(RoomData())
                                                HStack(spacing: 0) {
                                                    Text(usernameSplit[0])
                                                        .fontWeight(.medium)
                                                    Text(":" + usernameSplit[1])
                                                        .fontWeight(.light)
                                                }
                                            }
                                            if username == matrix.session.myUserId {
                                                Image(systemName: "checkmark.circle.fill")
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal, 8)
                                }
                                Button {
                                    matrix.addAccount()
                                } label: {
                                    Image(systemName: "plus")
                                    Text("Add account")
                                }
                                    .buttonStyle(.plain)
                                Spacer()
                            }
                        }
                }
            }
        }
        
        .toolbar {
            if activeConversation?.contains(":") == true {
                ConversationDetailToolbar(activeConversation: $activeConversation)
            } else {
                NavigationLink(destination: PreferencesView()) {
                    Label("About me", systemImage: "person.crop.circle")
                }
            }
        }
        
        .onChange(of: matrix.syncStatus) { _ in
            updateRoomStates()
        }
        .onChange(of: matrix.session.state) { _ in
            guard activeConversation == "loading" else { return }
            guard matrix.session.state != .initialised else { return }
            activeConversation = "recents"
        }
        .onChange(of: matrix.session.rooms) { _ in
            updateRoomStates()
        }
        .onChange(of: matrix.preferences.prioritizeRoomsWithActivity) { _ in
            updateRoomStates()
        }
    }
}

struct RoomLink: View {
    @EnvironmentObject private var matrix: MatrixModel

    let room: MXRoom
    @Binding var activeConversation: String?
    var icon: String = "number"

    var body: some View {
        NavigationLink(
            destination: ConversationDetail(channel: room),
            tag: room.roomId,
            selection: $activeConversation) {
                HStack {
                    if matrix.preferences.showRoomIconsInSidebar {
                        AvatarView(url: room.summary.avatar, height: 16.0, width: 16.0)
                    } else {
                        Image(systemName: icon)
                    }
                    Text(room.summary?.displayname ?? room.roomId)
                    if matrix.preferences.displayRoomActivityIndicators && room.summary?.hasAnyUnread == true {
                        Spacer()
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(room.summary?.hasAnyHighlight == true ? .red : .primary)
                    }
                }
        }
    }
}

struct ConversationList_Previews: PreviewProvider {
    static var previews: some View {
        ConversationList()
            .environmentObject(MatrixModel())
    }
}
