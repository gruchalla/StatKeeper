//
//  StatKeeperApp.swift
//  StatKeeper
//
//  Copyright © 2026 Kenny Gruchalla
//  Licensed under the MIT License. See LICENSE in the project root for license information.
//

import SwiftUI
import SwiftData

/// Application entry point configuring the SwiftData model container
/// and presenting the root ContentView.
@main
struct StatKeeperApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Provide a model container for PlayerRecord to the entire scene hierarchy.
        .modelContainer(for: PlayerRecord.self)
    }
}
