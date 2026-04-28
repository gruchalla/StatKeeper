//
//  StatKeeperApp.swift
//  StatKeeper
//
//  Created by Kenny Gruchalla on 4/25/26.
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
