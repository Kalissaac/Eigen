//
// CallInviteEventView.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK

struct CallInviteEventView: View {
    @EnvironmentObject private var matrix: MatrixModel

    let event: MXEvent

    var body: some View {
        EventView(event: event, hierarchy: .secondary) { user in
            HStack(spacing: 2) {
                Text(user.wrappedValue?.displayname ?? event.content["displayname"] as? String ?? event.sender)
                    .help(event.sender)
                Text("started a call")
            }
                .foregroundColor(.secondary)
                .font(.caption)
        }
    }
}

//struct CallInviteEventView_Previews: PreviewProvider {
//    static var previews: some View {
//        CallInviteEventView()
//    }
//}
