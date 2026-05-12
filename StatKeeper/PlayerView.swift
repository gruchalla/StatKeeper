//
//  PlayerView.swift
//  StatKeeper
//
//  Copyright © 2026 Kenny Gruchalla
//  Licensed under the MIT License. See LICENSE in the project root for license information.
//
import SwiftUI
import SwiftData
internal import Combine

/// The primary stat-tracking screen for a single player/session.
///
/// Data entered here is kept in local view state (PlayerState) until the user chooses
/// to save, at which point it is persisted as a PlayerRecord via SwiftData.
struct PlayerView: View {
    @Environment(\.modelContext) private var modelContext // Access the database context
    @Binding var editingRecord: PlayerRecord? // The record we are editing (if any)
    
    @State private var playerState = PlayerState()
    @State private var timerRunning : Bool = false
    @State private var startTime : Date = Date()
    @State private var showResetAlert = false
    @State private var showAbout: Bool = false

    /// A transient container for the live, unsaved stats in the UI.
    struct PlayerState {
        /// Made shots recorded as point values (1, 2, 3).
        var buckets: [Int] = []
        /// Missed shots recorded as point values (1, 2, 3).
        var misses: [Int] = []
        /// Box score counters.
        var rebounds: Int = 0
        var assists: Int = 0
        var steals: Int = 0
        var blocks: Int = 0
        /// Elapsed time on court in seconds (derived from the sub in/out timer).
        var timeIn: TimeInterval = 0
        /// Free-form notes for the current session.
        var notes: String = ""
        
        /// Total points scored.
        var points: Int { buckets.reduce(0, +) }
        /// Count of made free throws (1-pointers).
        var ones: Int { buckets.filter { $0 == 1 }.count }
        /// Count of made 2-pointers.
        var twos: Int { buckets.filter { $0 == 2}.count }
        /// Count of made 3-pointers.
        var threes: Int { buckets.filter { $0 == 3}.count }
        /// Count of missed free throws.
        var oneMisses: Int { misses.filter { $0 == 1 }.count }
        /// Count of missed 2-pointers.
        var twoMisses: Int { misses.filter { $0 == 2 }.count }
        /// Count of missed 3-pointers.
        var threeMisses: Int { misses.filter { $0 == 3 }.count }
        
        init() {}
        
        /// Loads an existing record into the transient state for editing.
        init(from record: PlayerRecord) {
            self.buckets = record.buckets
            self.misses = record.misses
            self.rebounds = record.rebounds
            self.assists = record.assists
            self.steals = record.steals
            self.blocks = record.blocks
            self.timeIn = record.timeIn
            self.notes = record.notes
        }
        
        /// Resets all stats and notes to their initial values.
        mutating func clear() { self = PlayerState() }
        
        /// Creates a persisted PlayerRecord snapshot from the current state.
        ///
        /// Use when saving to history. Note that the record's date is set by the model.
        func record() -> PlayerRecord {
            PlayerRecord(buckets: buckets,
                         misses: misses,
                         rebounds: rebounds,
                         assists: assists,
                         steals: steals,
                         blocks: blocks,
                         timeIn: timeIn,
                         notes: notes)
        }
        
        /// Updates an existing persisted record with the current state values.
        func update(_ record: PlayerRecord) {
            record.buckets = self.buckets
            record.misses = self.misses
            record.rebounds = self.rebounds
            record.assists = self.assists
            record.steals = self.steals
            record.blocks = self.blocks
            record.timeIn = self.timeIn
            record.notes = self.notes
        }
    }
    
    /// A circular button that visually indicates a “miss”
    struct MissButton: View {
        let label: String
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                ZStack {
                    Text(label)
                        .padding()
                        .frame(width: 45, height: 45)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .background(.ultraThinMaterial, in: Circle())
                        .background {
                                Circle().fill(Color.blue.opacity(0.6))
                        }
                        .overlay {
                            // Adds the 3D "rim" highlight
                            Circle()
                                .stroke(.white.opacity(0.2), lineWidth: 0.5)
                        }
                        .shadow(color: Color(.label).opacity(0.1), radius: 2, x: 0, y: 2)
                    Capsule()
                        .fill(Color.white)
                        .frame(width: 2, height: 44)
                        .rotationEffect(.degrees(45))
                    
                }
            }
            .accessibilityLabel(Text("Miss \(label)-point shot"))
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                // Shooting section: made shots and misses with per-value counts.
                VStack {
                    HStack{
                        Text("Shooting: ").font(.headline)
                        Spacer()
                        Text(playerState.ones, format:.number).frame(width: 45)
                        Text(playerState.twos, format:.number).frame(width: 45)
                        Text(playerState.threes, format:.number).frame(width: 45)
                    }
                    .padding(.bottom, 1)
                    
                    HStack {
                        // Undo last made shot.
                        MinusButton(action: {
                            _ = playerState.buckets.popLast()
                            Feedback.deleteWithSound()
                        })
                        
                        Spacer()
                        Text(playerState.points, format: .number).font(.title)
                        Spacer()
                        // +1, +2, +3 made shots
                        Button(action: {
                            playerState.buckets.append(1)
                            Feedback.tapWithSound()
                        }){
                            Text("1")
                                .padding()
                                .frame(width: 45, height: 45)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .background(.ultraThinMaterial, in: Circle())
                                .background {
                                        Circle().fill(Color.blue.opacity(0.6))
                                }
                                .overlay {
                                    // Adds the 3D "rim" highlight
                                    Circle()
                                        .stroke(.white.opacity(0.2), lineWidth: 0.5)
                                }
                                .shadow(color: Color(.label).opacity(0.1), radius: 2, x: 0, y: 2)
                        }
                        Button(action: {
                            playerState.buckets.append(2)
                            Feedback.tapWithSound()
                        }){
                            Text("2")
                                .padding()
                                .frame(width: 45, height: 45)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .background(.ultraThinMaterial, in: Circle())
                                .background {
                                        Circle().fill(Color.blue.opacity(0.6))
                                }
                                .overlay {
                                    // Adds the 3D "rim" highlight
                                    Circle()
                                        .stroke(.white.opacity(0.2), lineWidth: 0.5)
                                }
                                .shadow(color: Color(.label).opacity(0.1), radius: 2, x: 0, y: 2)
                        }
                        Button(action:{
                            playerState.buckets.append(3)
                            Feedback.tapWithSound()
                        }){
                            Text("3")
                                .frame(width: 45, height: 45)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .background(.ultraThinMaterial, in: Circle())
                                .background {
                                        Circle().fill(Color.blue.opacity(0.6))
                                }
                                .overlay {
                                    // Adds the 3D "rim" highlight
                                    Circle()
                                        .stroke(.white.opacity(0.2), lineWidth: 0.5)
                                }
                                .shadow(color: Color(.label).opacity(0.1), radius: 2, x: 0, y: 2)
                        }
                    }
                    HStack {
                        // Undo last missed shot.
                        MinusButton(action: {
                            _ = playerState.misses.popLast()
                            Feedback.deleteWithSound()
                        })
                        
                        Spacer()
                        // 1/2/3 missed shots
                        MissButton(label: "1", action: {
                            playerState.misses.append(1)
                            Feedback.tapWithSound()
                        })
                        MissButton(label: "2", action: {
                            playerState.misses.append(2)
                            Feedback.tapWithSound()
                            
                        })
                        MissButton(label: "3", action:{
                            playerState.misses.append(3)
                            Feedback.tapWithSound()
                        })
                        
                    }
                    HStack{
                        Text("Misses: ").foregroundColor(.red)
                        Spacer()
                        Text(playerState.oneMisses, format:.number).frame(width: 45).foregroundColor(.red)
                        Text(playerState.twoMisses, format:.number).frame(width: 45).foregroundColor(.red)
                        Text(playerState.threeMisses, format:.number).frame(width: 45).foregroundColor(.red)
                    }
                    .padding(.bottom, 1)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black, lineWidth: 1)
                )
                
                // Box score counters.
                HStack {
                    CounterView(label: "Assists:", color: Color.cyan, value: $playerState.assists)
                    CounterView(label: "Rebounds:", color: Color.green, value: $playerState.rebounds)
                }
                
                HStack {
                    CounterView(label: "Steals", color: Color.red, value: $playerState.steals)
                    CounterView(label: "Blocks", color: Color.orange, value: $playerState.blocks)
                }
                
                // Time-on-court controls and display.
                HStack {
                    // SUB IN: starts or resumes the timer. Adjusts startTime so it
                    // accounts for any previously accumulated timeIn.
                    Button(action: {
                        if !timerRunning {
                            // Adjust startTime so it accounts for time already elapsed
                            startTime = Date().addingTimeInterval(-playerState.timeIn)
                            timerRunning.toggle()
                            UIApplication.shared.isIdleTimerDisabled = true
                        }
                    }) {
                        VStack {
                            Image(systemName: "arrow.right.to.line")
                            Text("IN").font(.footnote).bold()
                        }
                    }
                    .frame(width: 50, height: 50)
                    //.background(timerRunning ? Color.black : Color.gray)
                    .background {
                        if timerRunning {
                            Circle()
                                .fill(Color.black)
                                // The "Sunken" Effect: Inner Shadow
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 6)
                                        .blur(radius: 4)
                                        .offset(x: -1, y: -2)
                                        .mask(Circle())
                                )
                        } else {
                            Circle()
                                .fill(Color.gray)
                                // The "Raised" Effect: Outer Shadow
                                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 3)
                        }
                    }
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .scaleEffect(timerRunning ? 0.9 : 1.0) // Looks pressed in
                    .shadow(color: .black.opacity(timerRunning ? 0 : 0.3), radius: 4, x: 0, y: 4)
                    .animation(.spring(response: 0.3), value: timerRunning)
                    .accessibilityLabel(Text("Sub in"))
                    
                    Spacer()
                    Text(formatTime(playerState.timeIn))
                        .font(.title)
                        .accessibilityLabel(Text("Time in"))
                        .accessibilityValue(Text(formatTime(playerState.timeIn)))
                    Spacer()
                    
                    // SUB OUT: pauses the timer and allows the device to sleep again.
                    Button(action: {
                        if timerRunning {
                            timerRunning.toggle()
                        }
                        UIApplication.shared.isIdleTimerDisabled = false
                    })
                    {
                        VStack {
                            Image(systemName: "arrow.left.to.line")
                            Text("OUT").font(.footnote).bold()
                        }
                        
                        .frame(width: 50, height: 50)
                        .background {
                            if !timerRunning {
                                Circle()
                                    .fill(Color.black)
                                    // The "Sunken" Effect: Inner Shadow
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 6)
                                            .blur(radius: 4)
                                            .offset(x: -1, y: -2)
                                            .mask(Circle())
                                    )
                            } else {
                                Circle()
                                    .fill(Color.gray)
                                    // The "Raised" Effect: Outer Shadow
                                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 3)
                            }
                        }
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .scaleEffect(!timerRunning ? 0.9 : 1.0)
                        .shadow(color: .black.opacity(!timerRunning ? 0 : 0.3), radius: 4, x: 0, y: 4)
                        .animation(.spring(response: 0.3), value: timerRunning)
                    }
                    .accessibilityLabel(Text("Sub out"))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.label).opacity(0.35))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black, lineWidth: 1)
                )
                // Timer tick: update elapsed time while running based on wall-clock.
                .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
                    if timerRunning {
                        // Update the elapsed time based on real world time
                        playerState.timeIn = Date().timeIntervalSince(startTime)
                    }
                }
                
                // Notes capture.
                VStack(alignment: .leading) {
                    Text("Notes")
                        .font(.headline)
                    
                    TextEditor(text: $playerState.notes)
                        .frame(height: 80) // Give it some space
                        .padding(4)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                }
                .toolbar {
                    // Dismiss keyboard from the accessory toolbar.
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                }
                Divider()
                
                // Actions: reset/save and copy summary.
                HStack{
                    Spacer()
                    // Reset with confirmation; can save & reset or just reset.
                    Button(action: {
                        showResetAlert = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset")
                                .font(.subheadline)
                        }
                        .padding()
                        .foregroundColor(Color(.label))
                        .background(Color(.systemGray6))
                        .background(.ultraThinMaterial, in:RoundedRectangle(cornerRadius: 8))
                        
                    }
                    .alert("Are you sure?", isPresented: $showResetAlert) {
                        Button("Save & Reset", role: .destructive) {
                            savePlayer()
                        }
                        Button("Reset", role: .destructive) {
                            clearStats()
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("Reset your counters.")
                    }
                    .accessibilityLabel(Text("Save and reset"))
                    //Spacer()
                    // Copy a human-readable summary to the clipboard.
                    Button(action: {
                        UIPasteboard.general.string = playerState.record().prettyPrint()
                        Feedback.copied()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.on.doc")
                            Text("Copy")
                                .font(.subheadline)
                        }
                        .padding()
                        .foregroundColor(Color(.label))
                        .background(Color(.systemGray6))
                        .background(.thickMaterial, in:RoundedRectangle(cornerRadius: 8))

                    }
                    .accessibilityLabel(Text("Copy summary"))
                    Spacer()
                    Button {
                        showAbout = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .accessibilityLabel(Text("About"))
                }
                .sheet(isPresented: $showAbout) {
                    // Replace PlaceholderAboutView with your real AboutView when available.
                    InfoView()
                }
                }
            .padding()
                
            }
            .padding()

        // Load or clear the UI when editingRecord changes.
        .onChange(of: editingRecord) { _, newValue in
            timerRunning = false
            UIApplication.shared.isIdleTimerDisabled = false
            if let record = newValue {
                playerState = PlayerState(from: record)
            } else {
                playerState.clear()
            }
        }
    }
    
    /// Clears all current stats and stops the timer.
    private func clearStats() {
        playerState.clear()
        editingRecord = nil
        timerRunning = false
    }

    /// Persists the current PlayerState as a PlayerRecord and then resets the UI.
    private func savePlayer() {
        if (editingRecord != nil) {
            playerState.update(editingRecord!)
        }
        else {
            modelContext.insert(playerState.record())
        }
        UIPasteboard.general.string = playerState.record().prettyPrint()
        clearStats()
    }
    
    /// Formats a time interval (seconds) as mm:ss for display.
    ///
    /// - Parameter time: The elapsed time in seconds.
    /// - Returns: A string in the format "MM:SS".
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
}

