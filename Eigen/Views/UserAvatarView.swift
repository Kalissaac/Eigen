//
// UserAvatarView.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK
import CachedAsyncImage

struct UserAvatarView: View {
    @EnvironmentObject var matrix: MatrixModel
    @EnvironmentObject var roomData: RoomData
    let user: MXUser?
    let height: CGFloat
    let width: CGFloat

    var body: some View {
        CachedAsyncImage(url: normalizeAvatarURL()) { image in
            image
                .resizable()
        } placeholder: {
            GeometryReader { metrics in
                VStack {
                    HStack {
                        Image(systemName: "person")
                            .resizable()
                            .frame(width: metrics.size.width * 0.5, height: metrics.size.height * 0.5, alignment: .center)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.quaternary)
            }
        }
        .frame(width: width, height: height, alignment: .topLeading)
        .clipShape(Circle())
    }

    func normalizeAvatarURL() -> URL {
        let fallbackImageURL = "https://example.com/avatar.png"
        var url = URL(string: user?.avatarUrl ?? fallbackImageURL)!
        if let roomDataUser = roomData.members.member(withUserId: user?.userId) {
            url = URL(string: roomDataUser.avatarUrl)!
        }
        if url.scheme == "mxc" {
            let thumbnailURL = matrix.session.mediaManager.url(
                ofContentThumbnail: url.absoluteString,
                toFitViewSize: CGSize(width: width, height: height),
                with: .init(1)
            )
            url = URL(string: thumbnailURL ?? fallbackImageURL)!
        }
        return url
    }
}

//struct UserAvatarView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserAvatarView()
//    }
//}
