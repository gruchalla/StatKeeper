//
//  ContentView.swift
//  StatKeeper
//
//  Created by Kenny Gruchalla on 4/25/26.
//

import SwiftUI
import SwiftData

internal import Combine

/// The root view hosting the primary tabs:
/// - Counters: live stat tracking
/// - Log: saved session history
struct ContentView: View {
    @State private var editingRecord: PlayerRecord? = nil
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            PlayerView(editingRecord: $editingRecord)
                .tabItem {
                    Label(LocalizedStringKey("Counters"), systemImage: "sportscourt.fill")
                }
                .tag(0)

            HistoryView(editingRecord: $editingRecord, selectedTab: $selectedTab)
                .tabItem {
                    Label(LocalizedStringKey("Log"), systemImage: "list.bullet.rectangle.fill")
                }
                .tag(1)

            ChartView()
                .tabItem {
                    Label(LocalizedStringKey("Charts"), systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)
        }
        .tabViewStyle(.automatic)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: PlayerRecord.self, inMemory: true)
}

