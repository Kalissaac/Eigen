//
// UserAvatarView.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK
import CachedAsyncImage

struct UserAvatarView: View {
    @EnvironmentObject private var matrix: MatrixModel
    @EnvironmentObject private var roomData: RoomData
    @Binding var user: MXUser?
    let height: CGFloat
    let width: CGFloat
    @State private var url: String?

    var body: some View {
        AvatarView(url: url, height: height, width: width)
            .onAppear(perform: normalizeAvatarURL)
    }

    func normalizeAvatarURL() -> Void {
        url = user?.avatarUrl
        if let roomUser = roomData.members.member(withUserId: user?.userId), roomUser.avatarUrl != "" {
            url = roomUser.avatarUrl
        }
    }
}

struct UserAvatarView_Previews: PreviewProvider {
    static var previews: some View {
        UserAvatarView(user: .constant(nil), height: 16.0, width: 16.0)
            .environmentObject(RoomData())
    }
}
