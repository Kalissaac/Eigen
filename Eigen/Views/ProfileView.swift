//
// ProfileView.swift
// Eigen
//
        

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var matrix: MatrixModel
    
    var body: some View {
        VStack {
            Text(matrix.session.credentials.userId ?? "unknown user id")
            Button("Log out") {
                matrix.logout()
            }
        }
        .padding()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
