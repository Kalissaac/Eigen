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
            ContentView()
                .environmentObject(matrixModel)
        }
    }
}

extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}
