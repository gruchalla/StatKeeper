//
//  PlayerRecord.swift
//  StatKeeper
//
//  Created by Kenny Gruchalla on 4/27/26.
//
import SwiftUI
import SwiftData

/// A persisted snapshot of a player's stats for a single session or game.
///
/// Stores raw events (buckets, misses) and derived stats (percentages, attempts)
/// are computed on demand from the raw arrays and counts.
@Model
class PlayerRecord: Identifiable {
    /// Unique identifier for the record.
    var id: UUID = UUID()
    /// When the record was created/saved.
    var date: Date = Date()
    
    /// Scored buckets as point values (1, 2, or 3).
    var buckets: [Int]
    /// Missed shots as point values (1, 2, or 3).
    var misses: [Int]
    
    /// Box score counts.
    var rebounds: Int
    var assists: Int
    var steals: Int
    var blocks: Int
    
    /// Time on court in seconds.
    var timeIn: TimeInterval
    /// Free-form notes attached to this record.
    var notes: String

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
    
    /// Attempts by shot type.
    var freeThrowAttempts: Int { ones + oneMisses }
    var twoPointAttempts: Int { twos + twoMisses }
    var threePointAttempts: Int { threes + threeMisses }
    
    /// Field goals made (2s + 3s).
    var fieldGoals: Int { twos + threes }
    /// Field goal attempts (2s + 3s attempts).
    var fieldGoalAttempts: Int { twoPointAttempts + threePointAttempts }
    
    /// Free throw percentage (0 if no attempts).
    var ftPercentage: Float { freeThrowAttempts == 0 ? 0.0 : Float(ones) / Float(freeThrowAttempts) }
    /// Field goal percentage (0 if no attempts).
    var fgPercentage: Float { fieldGoalAttempts == 0 ? 0.0 : Float(fieldGoals) / Float(fieldGoalAttempts) }
    /// 3-point percentage (0 if no attempts).
    var threePointPercentage: Float { threePointAttempts == 0 ? 0.0 : Float(threes) / Float(threePointAttempts) }
    
    /// Whole minutes on court (truncates seconds).
    var minutesIn: Int { Int(timeIn) / 60 }
    
    /// Designated initializer.
    ///
    /// - Parameters:
    ///   - buckets: Array of made shot values (1/2/3).
    ///   - misses: Array of missed shot values (1/2/3).
    ///   - rebounds: Total rebounds.
    ///   - assists: Total assists.
    ///   - steals: Total steals.
    ///   - blocks: Total blocks.
    ///   - timeIn: Time on court in seconds.
    ///   - notes: Free-form notes.
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
    
    /// Produces a human-readable multi-line summary of the record.
    ///
    /// - Returns: A newline-separated string suitable for sharing or copying.
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
