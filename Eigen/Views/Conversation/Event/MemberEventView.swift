//
// MemberEvent.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK

struct MemberEventView: View {
    @EnvironmentObject var matrix: MatrixModel

    let event: MXEvent
    
    var body: some View {
        HStack {
            Text("\(event.content["displayname"] as? String ?? "unknown name") \(event.content["membership"] as? String ?? "unknown action") the room")
        }
    }
}

//struct MemberEvent_Previews: PreviewProvider {
//    static var previews: some View {
//        MemberEventView()
//    }
//}
