//
// EigenApp.swift
// Eigen
//
        

import SwiftUI
import MatrixSDK

@main
struct EigenApp: App {
    @StateObject var matrixModel = MatrixModel()
    
    var body: some Scene {
        WindowGroup {
            switch matrixModel.authenticationStatus {
            case .authenticated:
                ContentView()
                    .environmentObject(matrixModel)
            case .notAuthenticated:
                LoginView()
                    .environmentObject(matrixModel)
            default:
                ProgressView()
            }
        }
    }
}
