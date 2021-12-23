//
// ConversationDetail.swift
// Eigen
//
        

import SwiftUI

struct ConversationDetail: View {
    var conversationId: String
    @Binding var messageInputText: String
    
    var body: some View {
        VStack {
            Group {
                Text("Hello, World!")
                Text("Conversation ID: \(conversationId)")
            }
            
            HStack {
                TextField("Send message", text: $messageInputText)
//                    .foc
            }
        }
    }
}

struct ConversationDetail_Previews: PreviewProvider {
    static var previews: some View {
        ConversationDetail(conversationId: "1", messageInputText: .constant(""))
    }
}
