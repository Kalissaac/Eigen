//
// MessageEventView.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK
import CachedAsyncImage

struct MessageEventView: View {
    @EnvironmentObject private var matrix: MatrixModel

    let message: MessageEvent
    @State private var user: MXUser?
    
    var body: some View {
        HStack {
            UserAvatarView(user: user, height: 28, width: 28)
            VStack {
                HStack {
                    Text(user?.displayname ?? message.sender)
                        .fontWeight(.semibold)
                    Text(formatDate(message.timestamp))
                        .foregroundColor(.secondary)
                        .fontWeight(.light)
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
        user = matrix.session.getOrCreateUser(message.sender)
    }

    func formatDate(_ timestamp: UInt64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp / 1000))
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        if Calendar.autoupdatingCurrent.isDateInToday(date) {
            formatter.dateStyle = .none
            return formatter.string(from: date)
        }
        return formatter.string(from: date)
    }
}

//struct ConversationMessage_Previews: PreviewProvider {
//    static var previews: some View {
//        ConversationMessage(message: MessageEvent(id: "", timestamp: 1640239022240, sender: "", content: "test", roomId: ""))
//    }
//}
