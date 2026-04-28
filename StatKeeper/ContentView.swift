//
//  ContentView.swift
//  StatKeeper
//
//  Created by Kenny Gruchalla on 4/25/26.
//

import SwiftUI
import SwiftData

internal import Combine

struct ContentView: View {

    var body: some View {
        TabView {
            PlayerView()
                .tabItem {
                    Label(LocalizedStringKey("Counters"), systemImage: "sportscourt.fill")
                }
            HistoryView()
                .tabItem {
                    Label(LocalizedStringKey("Log"), systemImage: "list.bullet.rectangle.fill")
                }
        }
        .tabViewStyle(.automatic)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}


#Preview {
    ContentView()
        .modelContainer(for: PlayerRecord.self, inMemory: true)
}
