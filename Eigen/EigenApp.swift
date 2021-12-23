//
// EigenApp.swift
// Eigen
//
        

import SwiftUI

@main
struct EigenApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}
