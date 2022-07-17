//
// ConversationDetailToolbar.swift
// Eigen
//
        

import SwiftUI

struct ConversationDetailToolbar: View {
    @EnvironmentObject private var matrix: MatrixModel
    @State private var showDetailInfo = false
    @Binding var activeConversation: String?

    var body: some View {
        if activeConversation?.contains(":") == true {
            Button(action: { showDetailInfo = true }) {
                Label("About this conversation", systemImage: "info.circle")
            }
            .popover(isPresented: $showDetailInfo, arrowEdge: .bottom) {
                ConversationDetailInfo(channel: matrix.session.room(withRoomId: activeConversation))
            }
        }
    }
}

struct ConversationDetailToolbar_Previews: PreviewProvider {
    static var previews: some View {
        ConversationDetailToolbar(activeConversation: .constant(""))
    }
}
