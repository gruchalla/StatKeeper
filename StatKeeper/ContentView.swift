//
//  ContentView.swift
//  StatKeeper
//
//  Created by Kenny Gruchalla on 4/25/26.
//

import SwiftUI
import AudioToolbox
internal import Combine

struct GameRecord: Identifiable {
    let id = UUID()
    let date = Date()
    let buckets: [Int]
    let misses: [Int]
    let points: Int
    let rebounds: Int
    let assists: Int
    let steals: Int
    let blocks: Int
    let timeIn: TimeInterval
    let notes: String
}

struct ContentView: View {
    @State private var history: [GameRecord] = []

    var body: some View {
        TabView {
            CountsView(history: $history)
                .tabItem {
                    Label("Counters", systemImage: "sportscourt.fill")
                }
            HistoryView(history: $history)
                .tabItem {
                    Label("Log", systemImage: "list.bullet.rectangle.fill")
                }
        }
        .tabViewStyle(.automatic)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct CountsView: View {
    @State private var buckets: [Int] = []
    @State private var misses: [Int] = []
    @State private var ones = 0
    @State private var twos = 0
    @State private var threes = 0
    @State private var points = 0
    @State private var one_misses = 0
    @State private var two_misses = 0
    @State private var three_misses = 0
    @State private var rebounds = 0
    @State private var assists = 0
    @State private var steals = 0
    @State private var blocks = 0
    
    @State private var timeIn: TimeInterval = 0
    @State private var timerRunning = false
    @State private var startTime = Date()

    @State private var notes: String = ""

    @State private var showResetAlert = false
    @Binding var history: [GameRecord]

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
                        Button(action: {
                            if let unwrappedBucket = buckets.popLast() {
                                points -= unwrappedBucket
                            }
                            playSystemClick(soundID:1123)
                            ones = buckets.filter { $0 == 1 }.count
                            twos = buckets.filter { $0 == 2 }.count
                            threes = buckets.filter { $0 == 3 }.count
                        }){
                            Text("-")
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color(.label))
                                .clipShape(Circle())
                                .overlay(Circle()
                                            .stroke(Color(.label).opacity(0.2), lineWidth: 4)
                                            .blur(radius: 4)
                                            .offset(x: 2, y: 2)
                                            .mask(Circle()))
                        }
                        
                        Spacer()
                        Text(points, format: .number).font(.title)
                        Spacer()
                        Button(action: {
                            buckets.append(1)
                            points += 1
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
                            buckets.append(2)
                            points += 2
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
                            buckets.append(3)
                            points += 3
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
                        Button(action: {
                            if !misses.isEmpty {
                                misses.removeLast()
                            }
                            playSystemClick(soundID:1123)
                            one_misses = misses.filter { $0 == 1 }.count
                            two_misses = misses.filter { $0 == 2 }.count
                            three_misses = misses.filter { $0 == 3 }.count
                        }){
                            Text("-")
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color(.label))
                                .clipShape(Circle())
                                .overlay(Circle()
                                            .stroke(Color(.label).opacity(0.2), lineWidth: 4)
                                            .blur(radius: 4)
                                            .offset(x: 2, y: 2)
                                            .mask(Circle()))

                        }
                        Spacer()
                        Button(action: {
                            misses.append(1)
                            one_misses += 1
                            playSystemClick()
                        }){
                            ZStack {
                                Text("1")
                                    .padding()
                                    .frame(width: 45, height: 45)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                Capsule()
                                    .fill(Color.white)
                                    .frame(width: 4, height: 50)
                                    .rotationEffect(.degrees(45))
                            }
                        }
                        Button(action: {
                            misses.append(2)
                            two_misses += 1
                            playSystemClick()

                        }){
                            ZStack {
                                Text("2")
                                    .padding()
                                    .frame(width: 45, height: 45)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                Capsule()
                                    .fill(Color.white)
                                    .frame(width: 4, height: 50)
                                    .rotationEffect(.degrees(45))
                            }
                        }
                        Button(action:{
                            misses.append(3)
                            three_misses += 1
                            playSystemClick()
                        }){
                            ZStack {
                                Text("3")
                                    .padding()
                                    .frame(width: 45, height: 45)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                Capsule()
                                    .fill(Color.white)
                                    .frame(width: 4, height: 50)
                                    .rotationEffect(.degrees(45))
                            }
                        }
                    
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
                            Button(action: {
                                rebounds -= rebounds == 0 ? 0 : 1
                                playSystemClick()
                            }){
                                Text("-")
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(Color(.label))
                                    .clipShape(Circle())
                                    .overlay(Circle()
                                        .stroke(Color(.label).opacity(0.2), lineWidth: 4)
                                        .blur(radius: 4)
                                        .offset(x: 2, y: 2)
                                        .mask(Circle()))
                            }
                            
                            Spacer()
                            Text(rebounds, format: .number).bold()
                            Spacer()

                            Button(action: {
                                rebounds += 1
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
                            Button(action: {
                                assists -= assists == 0 ? 0 : 1
                                playSystemClick()
                            }){
                                Text("-")
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(Color(.label))
                                    .clipShape(Circle())
                                    .overlay(Circle()
                                        .stroke(Color(.label).opacity(0.2), lineWidth: 4)
                                        .blur(radius: 4)
                                        .offset(x: 2, y: 2)
                                        .mask(Circle()))
                            }
                            
                            Spacer()
                            Text(assists, format: .number).bold()
                            Spacer()

                            Button(action: {
                                assists += 1
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
                            Button(action: {
                                steals -= steals == 0 ? 0 : 1
                                playSystemClick()
                            }){
                                Text("-")
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(Color(.label))
                                    .clipShape(Circle())
                                    .overlay(Circle()
                                        .stroke(Color(.label).opacity(0.2), lineWidth: 4)
                                        .blur(radius: 4)
                                        .offset(x: 2, y: 2)
                                        .mask(Circle()))
                            }
                            
                            Spacer()
                            Text(steals, format: .number).bold()
                            Spacer()
                            Button(action: {
                                steals += 1
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
                            Button(action: {
                                blocks -= blocks == 0 ? 0 : 1
                                playSystemClick()
                            }){
                                Text("-")
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(Color(.label))
                                    .clipShape(Circle())
                                    .overlay(Circle()
                                                .stroke(Color(.label).opacity(0.2), lineWidth: 4)
                                                .blur(radius: 4)
                                                .offset(x: 2, y: 2)
                                                .mask(Circle()))
                            }
                            
                            Spacer()
                            Text(blocks, format: .number).bold()
                            Spacer()
                            Button(action: {
                                blocks += 1
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
                            startTime = Date().addingTimeInterval(-timeIn)
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
                    Text(formatTime(timeIn))
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
                        timeIn = Date().timeIntervalSince(startTime)
                    }
                }
                VStack(alignment: .leading) {
                    Text("Game Notes")
                        .font(.headline)
                    
                    TextEditor(text: $notes)
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
                        let ft = Float(ones) / Float(ones  + one_misses)
                        let fg = Float(twos+threes) / Float(twos + two_misses + threes + three_misses)
                        let p3 = Float(threes) / Float(threes + three_misses)
                        let minutes = Int(timeIn) / 60
                        
                        // Copies the value to the system clipboard
                        let parts: [String?] = [
                            notes,
                            points > 0 ? "PTS \(points)" : nil,
                            ones > 0 || one_misses > 0 ? "   FT  \(ones)/\(ones+one_misses)  (\(ft.formatted(.percent.precision(.fractionLength(0)))))" : nil,
                            twos > 0 || two_misses > 0 ? "   FG \(twos+threes)/\(twos+two_misses+threes+three_misses)  (\(fg.formatted(.percent.precision(.fractionLength(0)))))" : nil,
                            threes > 0 || three_misses > 0 ? "   3P  \(threes)/\(threes+three_misses)  (\(p3.formatted(.percent.precision(.fractionLength(0)))))" : nil,
                            rebounds > 0 ? "REB \(rebounds)" : nil,
                            assists > 0 ? "AST \(assists)" : nil,
                            steals > 0 ? "STL \(steals)" : nil,
                            blocks > 0 ? "BLK \(blocks)" : nil,
                            "MIN \(minutes)"
                        ]

                        UIPasteboard.general.string = parts
                            .compactMap { $0 } // Removes all the 'nil' entries
                            .joined(separator: "\n")
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
    
    func clearStats() {
        points = 0
        rebounds = 0
        assists = 0
        steals = 0
        blocks = 0
        ones = 0
        twos = 0
        threes = 0
        one_misses = 0
        two_misses = 0
        three_misses = 0
        buckets = []
        misses = []
        timeIn = 0
        timerRunning = false
        notes = ""
    }

    func saveGame() {
        // Initialize a new record using current state values
        let newRecord = GameRecord(
            buckets: buckets,
            misses: misses,
            points: points,
            rebounds: rebounds,
            assists: assists,
            steals: steals,
            blocks: blocks,
            timeIn: timeIn,
            notes: notes
        )
        
        // Add it to your bound history array
        history.insert(newRecord, at: 0)
        
        clearStats()
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct HistoryView: View {
    @Binding var history: [GameRecord]

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
                                        history.remove(at: index)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }


            }
        }
    }
}

func playSystemClick(soundID: SystemSoundID = 1104) {
    // 1104 is the standard "tink" sound
    AudioServicesPlaySystemSound(soundID)
}

#Preview {
    ContentView()
}
