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
    let user: MXUser?
    let height: CGFloat
    let width: CGFloat
    @State private var normalizedURL: String?

    var body: some View {
        AvatarView(url: normalizedURL, height: height, width: width)
            .onAppear(perform: normalizeAvatarURL)
    }

    func normalizeAvatarURL() -> Void {
        let fallbackImageURL = "https://example.com/avatar.png"
        var url = URL(string: user?.avatarUrl ?? fallbackImageURL)!
        if let roomDataUser = roomData.members.member(withUserId: user?.userId) {
            if roomDataUser.avatarUrl != "" {
                url = URL(string: roomDataUser.avatarUrl)!
            }
        }
        if url.scheme == "mxc" {
            let thumbnailURL = matrix.session.mediaManager.url(
                ofContentThumbnail: url.absoluteString,
                toFitViewSize: CGSize(width: width, height: height),
                with: .init(1)
            )
            url = URL(string: thumbnailURL ?? fallbackImageURL)!
        }
        normalizedURL = url.absoluteString
    }
}

//struct UserAvatarView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserAvatarView()
//    }
//}
