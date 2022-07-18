//
// MemberEventView.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK

struct MemberEventView: View {
    @EnvironmentObject private var matrix: MatrixModel

    let event: MXEvent

    var body: some View {
        EventView(event: event, hierarchy: .secondary) { user in
            HStack(spacing: 2) {
                Text(user.wrappedValue?.displayname ?? event.content["displayname"] as? String ?? event.sender)
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
        }
    }
}

//struct MemberEvent_Previews: PreviewProvider {
//    static var previews: some View {
//        MemberEventView()
//    }
//}
