//
// MemberEvent.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK

struct CallInviteEventView: View {
    @EnvironmentObject private var matrix: MatrixModel

    let event: MXEvent
    @State private var user: MXUser?

    var body: some View {
        HStack {
            UserAvatarView(user: user, height: 18, width: 18)
                .padding(.horizontal, 4)
            HStack(spacing: 2) {
                Text(user?.displayname ?? event.content["displayname"] as? String ?? event.sender)
                    .help(event.sender)
                Text("started a call")
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
