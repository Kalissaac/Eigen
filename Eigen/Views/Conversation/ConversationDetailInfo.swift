//
// ConversationDetailInfo.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK

struct ConversationDetailInfo: View {
    @EnvironmentObject private var matrix: MatrixModel
    
    var channel: MXRoom
    
    var body: some View {
        VStack {
            DisclosureGroup("Conversation ID") {
                Text(channel.roomId)
            }
        }
        .padding()
    }
}

//struct ConversationDetailInfo_Previews: PreviewProvider {
//    static var previews: some View {
//        ConversationDetailInfo()
//    }
//}
