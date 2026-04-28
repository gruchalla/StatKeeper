//
//  PlayerRecord.swift
//  StatKeeper
//
//  Created by Kenny Gruchalla on 4/27/26.
//
import SwiftUI
import SwiftData

@Model
class PlayerRecord: Identifiable {
    var id: UUID = UUID()
    var date: Date = Date()
    var buckets: [Int]
    var misses: [Int]
    var rebounds: Int
    var assists: Int
    var steals: Int
    var blocks: Int
    var timeIn: TimeInterval
    var notes: String

    var points: Int { buckets.reduce(0, +) }
    var ones: Int { buckets.filter { $0 == 1 }.count }
    var twos: Int { buckets.filter { $0 == 2}.count }
    var threes: Int { buckets.filter { $0 == 3}.count }
    var oneMisses: Int { misses.filter { $0 == 1 }.count }
    var twoMisses: Int { misses.filter { $0 == 2 }.count }
    var threeMisses: Int { misses.filter { $0 == 3 }.count }
    
    var freeThrowAttempts: Int { ones + oneMisses }
    var twoPointAttempts: Int { twos + twoMisses }
    var threePointAttempts: Int { threes + threeMisses }
    var fieldGoals: Int { twos + threes }
    var fieldGoalAttempts: Int { twoPointAttempts + threePointAttempts }
    var ftPercentage: Float { freeThrowAttempts == 0 ? 0.0 : Float(ones) / Float(freeThrowAttempts) }
    var fgPercentage: Float { fieldGoalAttempts == 0 ? 0.0 : Float(fieldGoals) / Float(fieldGoalAttempts) }
    var threePointPercentage: Float { threePointAttempts == 0 ? 0.0 : Float(threes) / Float(threePointAttempts) }
    
    var minutesIn: Int { Int(timeIn) / 60 }
    
    init(buckets: [Int], misses: [Int], rebounds: Int, assists: Int, steals: Int, blocks: Int, timeIn: TimeInterval, notes: String) {
        self.buckets = buckets
        self.misses = misses
        self.rebounds = rebounds
        self.assists = assists
        self.steals = steals
        self.blocks = blocks
        self.timeIn = timeIn
        self.notes = notes
    }
    
    func prettyPrint() -> String {
        // Copies the value to the system clipboard
        let parts: [String?] = [
            self.notes,
            self.points > 0 ? "PTS: \(self.points)" : nil,
            self.freeThrowAttempts > 0 ? "FT%: \(self.ftPercentage.formatted(.percent.precision(.fractionLength(0))))" : nil,
            self.fieldGoalAttempts > 0 ? "FG%: \(self.fgPercentage.formatted(.percent.precision(.fractionLength(0))))" : nil,
            self.threePointAttempts > 0 ? "3P%: \(self.threePointPercentage.formatted(.percent.precision(.fractionLength(0))))" : nil,
            self.rebounds > 0 ? "REB: \(self.rebounds)" : nil,
            self.assists > 0 ? "AST: \(self.assists)" : nil,
            self.steals > 0 ? "STL: \(self.steals)" : nil,
            self.blocks > 0 ? "BLK: \(self.blocks)" : nil,
            "MIN: \(self.minutesIn)",
            self.freeThrowAttempts > 0 ? "FTs: \(self.ones)/\(self.freeThrowAttempts)" : nil,
            self.twoPointAttempts > 0 ? "2Ps: \(self.twos)/\(self.twoPointAttempts)" : nil,
            self.threePointAttempts > 0 ? "3Ps: \(self.threes)/\(self.threePointAttempts)" : nil,
        ]

        return parts
            .compactMap { $0 } // Removes all the 'nil' entries
            .joined(separator: "\n")
    }
}
