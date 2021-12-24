//
// ConversationMessage.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK

struct ConversationMessage: View {
    @EnvironmentObject var matrix: MatrixModel

    var message: MessageEvent
    @State private var user: MXUser?
    
    var body: some View {
        HStack {
            AsyncImage(url: normalizeAvatarURL(user?.avatarUrl)) { image in
                image
                    .resizable()
            } placeholder: {
                VStack {
                    HStack {
                        Image(systemName: "person")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.background)
            }
            .frame(width: 28, height: 28, alignment: .topLeading)
            .clipShape(Circle())

            VStack {
                HStack {
                    Text(user?.displayname ?? message.sender)
                        .fontWeight(.semibold)
                    Text(formatDate(message.timestamp))
                        .foregroundColor(.secondary)
                        .fontWeight(.light)
//                        .font(.caption)
                        .padding(.leading, 2)
                }
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(message.content)
                    .foregroundColor(.secondary)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 2)
        }
        .onAppear(perform: fetchUser)
    }
    
    func fetchUser() {
        user = matrix.session.user(withUserId: message.sender)
    }
    
    func normalizeAvatarURL(_ rawURL: String?) -> URL {
        let fallbackImageURL = "https://example.com/avatar.png"
        var url = URL(string: rawURL ?? fallbackImageURL)!
        if url.scheme == "mxc" {
            let thumbnailURL = matrix.session.mediaManager.url(
                ofContentThumbnail: rawURL,
                toFitViewSize: CGSize(width: 64, height: 64),
                with: .init(1)
            )
            url = URL(string: thumbnailURL ?? fallbackImageURL)!
        }
        return url
    }

    func formatDate(_ timestamp: UInt64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(message.timestamp / 1000))
        if Calendar.autoupdatingCurrent.isDateInToday(date) {
            return date.formatted(date: .omitted, time: .shortened)
        }
        return date.formatted(date: .numeric, time: .shortened)
    }
}

//struct ConversationMessage_Previews: PreviewProvider {
//    static var previews: some View {
//        ConversationMessage(message: MessageEvent(id: "", timestamp: 1640239022240, sender: "", content: "test", roomId: ""))
//    }
//}
