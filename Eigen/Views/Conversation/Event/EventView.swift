//
// EventView.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK

enum EventViewHierarchy {
    case primary
    case secondary
}

struct EventView<Content: View>: View {
    @ViewBuilder private var content: (_ user: Binding<MXUser?>) -> Content

    @EnvironmentObject private var matrix: MatrixModel

    private var event: MXEvent
    @State private var user: MXUser? = nil

    // how prominent the event view should be
    private var hierarchy: EventViewHierarchy

    init(event: MXEvent, hierarchy: EventViewHierarchy = .primary, @ViewBuilder content: @escaping (_ user: Binding<MXUser?>) -> Content) {
        self.event = event
        self.hierarchy = hierarchy
        self.content = content
    }

    var body: some View {
        HStack {
            switch hierarchy {
            case .secondary:
                UserAvatarView(user: $user, height: 18, width: 18)
                    .padding(.horizontal, 5.5)
                content($user)
                    .padding(.leading, 1.5)
            default:
                UserAvatarView(user: $user, height: 28, width: 28)
                    .padding(.trailing, 2)
                content($user)
            }
        }
        .onAppear {
            user = matrix.session.getOrCreateUser(event.sender)
        }
    }
}

//struct EventView_Previews: PreviewProvider {
//    static var previews: some View {
//        EventView()
//    }
//}
