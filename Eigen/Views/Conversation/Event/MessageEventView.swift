//
// MessageEventView.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK
import CachedAsyncImage

struct MessageEventView: View {
    @EnvironmentObject var matrix: MatrixModel

    let message: MessageEvent
    @State private var user: MXUser?
    
    var body: some View {
        HStack {
            UserAvatarView(user: user, height: 28, width: 28, mediaManager: matrix.session.mediaManager)
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

    func formatDate(_ timestamp: UInt64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(message.timestamp / 1000))
        if Calendar.autoupdatingCurrent.isDateInToday(date) {
            return date.formatted(date: .omitted, time: .shortened)
        } else if Calendar.autoupdatingCurrent.isDateInYesterday(date) {
            return date.formatted(date: .numeric, time: .shortened)
        }
        return date.formatted(date: .numeric, time: .omitted)
    }
}

//struct ConversationMessage_Previews: PreviewProvider {
//    static var previews: some View {
//        ConversationMessage(message: MessageEvent(id: "", timestamp: 1640239022240, sender: "", content: "test", roomId: ""))
//    }
//}
