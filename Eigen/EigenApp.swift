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
                .handlesExternalEvents(preferring: Set(arrayLiteral: "*"), allowing: Set(arrayLiteral: "*"))
        }
            .commands {
                CommandGroup(replacing: CommandGroupPlacement.newItem) { }
            }
            .handlesExternalEvents(matching: Set(arrayLiteral: "*"))
    }

    init() {
        if !FileManager.default.fileExists(atPath: IMAGE_CACHE_DIRECTORY) {
            let _ = try? FileManager.default.createDirectory(atPath: IMAGE_CACHE_DIRECTORY, withIntermediateDirectories: true)
        }
    }
}
