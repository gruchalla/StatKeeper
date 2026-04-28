//
//  PlayerView.swift
//  StatKeeper
//
//  Created by Kenny Gruchalla on 4/27/26.
//
import SwiftUI
import SwiftData

import AudioToolbox
internal import Combine

func playSystemClick(soundID: SystemSoundID = 1104) {
    // 1104 is the standard "tink" sound
    AudioServicesPlaySystemSound(soundID)
}

struct PlayerView: View {
    @Environment(\.modelContext) private var modelContext // Access the database context
    
    @State private var playerState = PlayerState()
    @State private var timerRunning : Bool = false
    @State private var startTime : Date = Date()
    @State private var showResetAlert = false

    struct PlayerState {
        var buckets: [Int] = []
        var misses: [Int] = []
        var rebounds: Int = 0
        var assists: Int = 0
        var steals: Int = 0
        var blocks: Int = 0
        var timeIn: TimeInterval = 0
        var notes: String = ""
        
        var points: Int { buckets.reduce(0, +) }
        var ones: Int { buckets.filter { $0 == 1 }.count }
        var twos: Int { buckets.filter { $0 == 2}.count }
        var threes: Int { buckets.filter { $0 == 3}.count }
        var oneMisses: Int { misses.filter { $0 == 1 }.count }
        var twoMisses: Int { misses.filter { $0 == 2 }.count }
        var threeMisses: Int { misses.filter { $0 == 3 }.count }
        
        mutating func clear() { self = PlayerState() }

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
    }
    
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
                        .clipShape(Circle())
                    Capsule()
                        .fill(Color.white)
                        .frame(width: 2, height: 50)
                        .rotationEffect(.degrees(45))
                }
            }
        }
    }
        
    // Timer that "ticks" every 0.1 seconds
    //let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            VStack {
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
                        MinusButton(action: {
                            _ = playerState.buckets.popLast()
                            playSystemClick(soundID:1123)
                        })
                        
                        Spacer()
                        Text(playerState.points, format: .number).font(.title)
                        Spacer()
                        Button(action: {
                            playerState.buckets.append(1)
                            playSystemClick()
                        }){
                            Text("1")
                                .padding()
                                .frame(width: 45, height: 45)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        Button(action: {
                            playerState.buckets.append(2)
                            playSystemClick()
                        }){
                            Text("2")
                                .padding()
                                .frame(width: 45, height: 45)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        Button(action:{
                            playerState.buckets.append(3)
                            playSystemClick()
                        }){
                            Text("3")
                                .frame(width: 45, height: 45)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                    HStack {
                        MinusButton(action: {
                            _ = playerState.misses.popLast()
                            playSystemClick(soundID:1123)
                        })
                        
                        Spacer()
                        MissButton(label: "1", action: {
                            playerState.misses.append(1)
                            playSystemClick()
                        })
                        MissButton(label: "2", action: {
                            playerState.misses.append(2)
                            playSystemClick()

                        })
                        MissButton(label: "3", action:{
                            playerState.misses.append(3)
                            playSystemClick()
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
                
                HStack {
                    CounterView(label: "Assists:", color: Color.cyan, value: $playerState.assists)
                    CounterView(label: "Rebounds:", color: Color.green, value: $playerState.rebounds)
                }
                
                HStack {
                    CounterView(label: "Steals", color: Color.red, value: $playerState.steals)
                    CounterView(label: "Blocks", color: Color.orange, value: $playerState.blocks)
                }
                
                HStack {
                    // SUB IN
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
                    .background(timerRunning ? Color.black : Color.gray)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .scaleEffect(timerRunning ? 0.9 : 1.0) // Looks pressed in
                    .shadow(color: .black.opacity(timerRunning ? 0 : 0.3), radius: 4, x: 0, y: 4)
                    .animation(.spring(response: 0.3), value: timerRunning)
                    
                    Spacer()
                    Text(formatTime(playerState.timeIn))
                        .font(.title)
                    Spacer()
                    // SUB OUT
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
                            .background(!timerRunning ? Color.black : Color.gray)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .scaleEffect(!timerRunning ? 0.9 : 1.0)
                            .shadow(color: .black.opacity(!timerRunning ? 0 : 0.3), radius: 4, x: 0, y: 4)
                            .animation(.spring(response: 0.3), value: timerRunning)
                    }
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
                .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
                    if timerRunning {
                        // Update the elapsed time based on real world time
                        playerState.timeIn = Date().timeIntervalSince(startTime)
                    }
                }

                VStack(alignment: .leading) {
                    Text("Notes")
                        .font(.headline)
                    
                    TextEditor(text: $playerState.notes)
                        .frame(height: 150) // Give it some space
                        .padding(4)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                }
                .padding()
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                }
                HStack{
                    Button(action: {
                        showResetAlert = true
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title2)
                            .padding()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color(.label))
                            .clipShape(Circle())
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
                    
                    Button(action: {
                        UIPasteboard.general.string = playerState.record().prettyPrint()
                    }) {
                        Image(systemName: "doc.on.doc")
                            .padding(12)
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color(.label))
                            .clipShape(Circle())
                    }
                    Spacer()

                }
                
            }
            .padding()
        }
    }
    
    private func clearStats() {
        playerState.clear()
        timerRunning = false
    }

    private func savePlayer() {
        modelContext.insert(playerState.record())
        
        clearStats()
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
}
