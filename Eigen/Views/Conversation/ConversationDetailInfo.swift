//
// ConversationDetailInfo.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK

struct ConversationDetailInfo: View {
    @EnvironmentObject var matrix: MatrixModel
    
    var channel: MXRoom
    
    var body: some View {
        Text("Hello, World!")
    }
}

//struct ConversationDetailInfo_Previews: PreviewProvider {
//    static var previews: some View {
//        ConversationDetailInfo()
//    }
//}
