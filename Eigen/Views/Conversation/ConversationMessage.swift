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
            AsyncImage(url: URL(string: "https://i.redd.it/b8dnk9lu33631.jpg")) { image in
                image
                    .resizable()
            } placeholder: {
                Image(systemName: "person")
            }
            .frame(width: 24, height: 24, alignment: .leading)
            .clipShape(Circle())

            Text("\(user?.displayname ?? message.sender): \(message.content)")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear(perform: fetchUser)
    }
    
    func fetchUser() {
        user = matrix.session.user(withUserId: message.sender)
    }
}
