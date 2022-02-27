//
// MemberEvent.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK

struct MemberEventView: View {
    @EnvironmentObject var matrix: MatrixModel

    let event: MXEvent
    @State private var user: MXUser?

    var body: some View {
        HStack {
            UserAvatarView(user: user, height: 18, width: 18, mediaManager: matrix.session.mediaManager)
                .padding(.horizontal, 4)
            HStack(spacing: 2) {
                Text(user?.displayname ?? event.content["displayname"] as? String ?? event.sender)
                    .help(event.sender)
                switch event.content["membership"] as? String {
                case "join":
                    Text("joined")
                case "leave":
                    Text("left")
                case "invite":
                    Text("invited \(event.content["displayname"] as? String ?? "unknown user") to")
                case "ban":
                    Text("was banned from")
                case "knock":
                    Text("requested to join")
                default:
                    Text("unknown action")
                }
                Text("the room")
            }
                .foregroundColor(.secondary)
                .font(.caption)
                .padding(.leading, 3)
        }
        .onAppear(perform: fetchUser)
    }

    func fetchUser() {
        user = matrix.session.getOrCreateUser(event.sender)
    }
}

//struct MemberEvent_Previews: PreviewProvider {
//    static var previews: some View {
//        MemberEventView()
//    }
//}
