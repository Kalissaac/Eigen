//
// ContentView.swift
// Eigen
//
        

import SwiftUI

struct ContentView: View {
    @StateObject private var matrixModel = MatrixModel()
    
    var body: some View {
        switch matrixModel.authenticationStatus {
        case .authenticated:
            AuthenticatedContentView()
                .environmentObject(matrixModel)
        case .notAuthenticated:
            LoginView()
                .environmentObject(matrixModel)
        default:
            ProgressView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
