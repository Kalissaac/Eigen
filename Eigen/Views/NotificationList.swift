//
// NotificationList.swift
// Eigen
//
        

import SwiftUI

struct NotificationList: View {
    @EnvironmentObject private var matrix: MatrixModel

    var body: some View {
        Text("notifs").navigationTitle("Recent notifications")
        Text(String(matrix.session.missedNotificationsCount()))
    }
}

struct NotificationList_Previews: PreviewProvider {
    static var previews: some View {
        NotificationList()
    }
}
