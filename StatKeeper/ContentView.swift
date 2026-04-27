//
//  ContentView.swift
//  StatKeeper
//
//  Created by Kenny Gruchalla on 4/25/26.
//

import SwiftUI
import AudioToolbox
import SwiftData
internal import Combine


@Model
class GameRecord: Identifiable {
    var id: UUID = UUID()
    var date: Date = Date()
    var buckets: [Int]
    var misses: [Int]
    var points: Int
    var rebounds: Int
    var assists: Int
    var steals: Int
    var blocks: Int
    var timeIn: TimeInterval
    var notes: String

    init(buckets: [Int], misses: [Int], points: Int, rebounds: Int, assists: Int, steals: Int, blocks: Int, timeIn: TimeInterval, notes: String) {
        self.buckets = buckets
        self.misses = misses
        self.points = points
        self.rebounds = rebounds
        self.assists = assists
        self.steals = steals
        self.blocks = blocks
        self.timeIn = timeIn
        self.notes = notes
    }
    
    func copy() -> GameRecord {
        return GameRecord(
            buckets: self.buckets,
            misses: self.misses,
            points: self.points,
            rebounds: self.rebounds,
            assists: self.assists,
            steals: self.steals,
            blocks: self.blocks,
            timeIn: self.timeIn,
            notes: self.notes
        )
    }
    
    func clear() {
        self.buckets = []
        self.misses = []
        self.points = 0
        self.rebounds = 0
        self.assists = 0
        self.steals = 0
        self.blocks = 0
        self.timeIn = 0
        self.notes = ""
    }
    
    func prettyPrint() -> String {
        let ones = self.buckets.filter { $0 == 1 }.count
        let twos = self.buckets.filter { $0 == 2 }.count
        let threes = self.buckets.filter { $0 == 3 }.count
        
        let one_misses = self.misses.filter { $0 == 1 }.count
        let two_misses = self.misses.filter { $0 == 2 }.count
        let three_misses = self.misses.filter { $0 == 3 }.count
        
        let ft = Float(ones) / Float(ones  + one_misses)
        let fg = Float(twos+threes) / Float(twos + two_misses + threes + three_misses)
        let p3 = Float(threes) / Float(threes + three_misses)
        let minutes = Int(self.timeIn) / 60
        
        // Copies the value to the system clipboard
        let parts: [String?] = [
            self.notes,
            self.points > 0 ? "PTS \(self.points)" : nil,
            ones > 0 || one_misses > 0 ? "   FT  \(ones)/\(ones+one_misses)  (\(ft.formatted(.percent.precision(.fractionLength(0)))))" : nil,
            twos > 0 || two_misses > 0 ? "   FG \(twos+threes)/\(twos+two_misses+threes+three_misses)  (\(fg.formatted(.percent.precision(.fractionLength(0)))))" : nil,
            threes > 0 || three_misses > 0 ? "   3P  \(threes)/\(threes+three_misses)  (\(p3.formatted(.percent.precision(.fractionLength(0)))))" : nil,
            self.rebounds > 0 ? "REB \(self.rebounds)" : nil,
            self.assists > 0 ? "AST \(self.assists)" : nil,
            self.steals > 0 ? "STL \(self.steals)" : nil,
            self.blocks > 0 ? "BLK \(self.blocks)" : nil,
            "MIN \(minutes)"
        ]

        return parts
            .compactMap { $0 } // Removes all the 'nil' entries
            .joined(separator: "\n")
    }
}

struct ContentView: View {

    var body: some View {
        TabView {
            CountsView()
                .tabItem {
                    Label("Counters", systemImage: "sportscourt.fill")
                }
            HistoryView()
                .tabItem {
                    Label("Log", systemImage: "list.bullet.rectangle.fill")
                }
        }
        .tabViewStyle(.automatic)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct CountsView: View {
    @Environment(\.modelContext) private var modelContext // Access the database context

    @State private var record = GameRecord(
        buckets: [],
        misses: [],
        points: 0,
        rebounds: 0,
        assists: 0,
        steals: 0,
        blocks: 0,
        timeIn: 0,
        notes: ""
    )
    
    @State private var ones : Int = 0
    @State private var twos : Int = 0
    @State private var threes : Int = 0
    @State private var points : Int = 0
    @State private var one_misses : Int = 0
    @State private var two_misses : Int = 0
    @State private var three_misses : Int = 0
    @State private var timerRunning : Bool = false
    @State private var startTime : Date = Date()

    @State private var showResetAlert = false

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
    
    struct MinusButton: View {
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text("-")
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(.label))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color(.label).opacity(0.2), lineWidth: 4)
                            .blur(radius: 4)
                            .offset(x: 2, y: 2)
                            .mask(Circle())
                    )
            }
        }
    }
        
    // Timer that "ticks" every 0.1 seconds
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    HStack{
                        Text("Shooting: ").font(.headline)
                        Spacer()
                        Text(ones, format:.number).frame(width: 40)
                        Text(twos, format:.number).frame(width: 40)
                        Text(threes, format:.number).frame(width: 40)
                    }
                    .padding(.bottom, 1)
                    
                    HStack {
                        MinusButton(action: {
                            if let unwrappedBucket = record.buckets.popLast() {
                                record.points -= unwrappedBucket
                            }
                            playSystemClick(soundID:1123)
                            updateCounts()
                        })
                        
                        Spacer()
                        Text(record.points, format: .number).font(.title)
                        Spacer()
                        Button(action: {
                            record.buckets.append(1)
                            record.points += 1
                            ones += 1
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
                            record.buckets.append(2)
                            record.points += 2
                            twos += 1
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
                            record.buckets.append(3)
                            record.points += 3
                            threes += 1
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
                            if !record.misses.isEmpty {
                                record.misses.removeLast()
                            }
                            playSystemClick(soundID:1123)
                            updateCounts()
                        })
                        
                        Spacer()
                        MissButton(label: "1", action: {
                            record.misses.append(1)
                            one_misses += 1
                            playSystemClick()
                        })
                        MissButton(label: "2", action: {
                            record.misses.append(2)
                            two_misses += 1
                            playSystemClick()

                        })
                        MissButton(label: "3", action:{
                            record.misses.append(3)
                            three_misses += 1
                            playSystemClick()
                        })
                    
                    }
                    HStack{
                        Text("Misses: ").foregroundColor(.red)
                        Spacer()
                        Text(one_misses, format:.number).frame(width: 40).foregroundColor(.red)
                        Text(two_misses, format:.number).frame(width: 40).foregroundColor(.red)
                        Text(three_misses, format:.number).frame(width: 40).foregroundColor(.red)
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
                    //
                    // Rebounds
                    //
                    VStack {
                        HStack{
                            Text("Rebounds:").font(.footnote)
                            Spacer()
                            
                        }
                        .padding(.bottom, 1)
                        
                        HStack {
                            MinusButton(action: {
                                record.rebounds -= record.rebounds == 0 ? 0 : 1
                                playSystemClick()
                            })
                            
                            Spacer()
                            Text(record.rebounds, format: .number).bold()
                            Spacer()

                            Button(action: {
                                record.rebounds += 1
                                playSystemClick()
                            }){
                                Text("+")
                                    .frame(width: 35, height: 35)
                                    .background(Color.purple)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }
                            
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.purple.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    
                    //
                    // Assists
                    //
                    VStack {
                        HStack{
                            Text("Assists: ").font(.footnote)
                            Spacer()
                            
                        }
                        .padding(.bottom, 1)
                        
                        HStack {
                            MinusButton(action: {
                                record.assists -= record.assists == 0 ? 0 : 1
                                playSystemClick()
                            })
                            
                            Spacer()
                            Text(record.assists, format: .number).bold()
                            Spacer()

                            Button(action: {
                                record.assists += 1
                                playSystemClick()
                            }){
                                Text("+")
                                    .frame(width: 35, height: 35)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }
                            
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black, lineWidth: 1)
                    )
                }
                
                HStack {
                    //
                    // Steals
                    //
                    VStack {
                        HStack{
                            Text("Steals: ").font(.footnote)
                            Spacer()
                            
                        }
                        .padding(.bottom, 1)
                        
                        HStack {
                            MinusButton(action: {
                                record.steals -= record.steals == 0 ? 0 : 1
                                playSystemClick()
                            })
                            
                            Spacer()
                            Text(record.steals, format: .number).bold()
                            Spacer()
                            Button(action: {
                                record.steals += 1
                                playSystemClick()
                            }){
                                Text("+")
                                    .frame(width: 35, height: 35)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }
                            
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    
                    //
                    // Blocks
                    //
                    VStack {
                        HStack{
                            Text("Blocks: ").font(.footnote)
                            Spacer()
                            
                        }
                        .padding(.bottom, 1)
                        
                        HStack {
                            MinusButton(action: {
                                record.blocks -= record.blocks == 0 ? 0 : 1
                                playSystemClick()
                            })
                            
                            Spacer()
                            Text(record.blocks, format: .number).bold()
                            Spacer()
                            Button(action: {
                                record.blocks += 1
                                playSystemClick()
                            }){
                                Text("+")
                                    .frame(width: 35, height: 35)
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }
                            
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black, lineWidth: 1)
                    )
                }
                
                HStack {
                    // SUB IN
                    Button(action: {
                        if !timerRunning {
                            // Adjust startTime so it accounts for time already elapsed
                            startTime = Date().addingTimeInterval(-record.timeIn)
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
                    Text(formatTime(record.timeIn))
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
                .onReceive(timer) { _ in
                    if timerRunning {
                        // Update the elapsed time based on real world time
                        record.timeIn = Date().timeIntervalSince(startTime)
                    }
                }
                VStack(alignment: .leading) {
                    Text("Game Notes")
                        .font(.headline)
                    
                    TextEditor(text: $record.notes)
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
                            saveGame()
                        }
                        Button("Reset", role: .destructive) {
                            clearStats()
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("Reset your counters.")
                    }
                    
                    Button(action: {
                        UIPasteboard.general.string = record.prettyPrint()
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
    
    private func updateCounts() {
        ones = record.buckets.filter { $0 == 1 }.count
        twos = record.buckets.filter { $0 == 2 }.count
        threes = record.buckets.filter { $0 == 3 }.count
        
        one_misses = record.misses.filter { $0 == 1 }.count
        two_misses = record.misses.filter { $0 == 2 }.count
        three_misses = record.misses.filter { $0 == 3 }.count
    }
    
    private func clearStats() {
        record.clear()
        ones = 0
        twos = 0
        threes = 0
        one_misses = 0
        two_misses = 0
        three_misses = 0
        timerRunning = false
    }

    private func saveGame() {
        modelContext.insert(record.copy())
        
        clearStats()
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func playSystemClick(soundID: SystemSoundID = 1104) {
        // 1104 is the standard "tink" sound
        AudioServicesPlaySystemSound(soundID)
    }
}

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GameRecord.date, order: .reverse) var history: [GameRecord]

    var body: some View {
        List{
            ForEach(history) { record in
                let ones = Float(record.buckets.filter { $0 == 1 }.count)
                let twos = Float(record.buckets.filter { $0 == 2 }.count)
                let threes = Float(record.buckets.filter { $0 == 3 }.count)
                let one_misses = Float(record.misses.filter { $0 == 1 }.count)
                let two_misses = Float(record.misses.filter { $0 == 2 }.count)
                let three_misses = Float(record.misses.filter { $0 == 3 }.count)
                
                let ft = ones / (ones + one_misses)
                let fg = (twos + threes) / (twos + two_misses + threes + three_misses)
                let threep = threes / (threes + three_misses)
                
                let minutes = Int(record.timeIn) / 60
                
                VStack{
                    Text("\(record.date.formatted(date: .abbreviated, time: .shortened))")
                    Text(record.notes)
                    ScrollView(.horizontal) {
                        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 10) {
                            GridRow {
                                Text("PTS").bold()
                                Text("FT%").bold()
                                Text("FG%").bold()
                                Text("3P%").bold()
                                Text("REB").bold()
                                Text("AST").bold()
                                Text("STL").bold()
                                Text("BLK").bold()
                                Text("MIN").bold()
                            }
                            .padding(.vertical, 5)
                            
                            Divider()
                            
                            GridRow {
                                Text("\(record.points)")
                                Text("\(ft.formatted(.percent.precision(.fractionLength(0))))")
                                Text("\(fg.formatted(.percent.precision(.fractionLength(0))))")
                                Text("\(threep.formatted(.percent.precision(.fractionLength(0))))")
                                Text("\(record.rebounds)")
                                Text("\(record.assists)")
                                Text("\(record.steals)")
                                Text("\(record.blocks)")
                                Text("\(minutes)")
                            }
                        }
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    if let index = history.firstIndex(where: { $0.id == record.id }) {
                                        modelContext.delete(history[index])
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }


            }
        }
    }
}

#Preview {
    ContentView()
}
