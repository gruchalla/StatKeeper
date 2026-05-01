//
//  ChartView.swift
//  StatKeeper
//
//  Created by Kenny Gruchalla on 4/27/26.
//
import SwiftUI
import SwiftData
import Charts

/// Visualizes saved PlayerRecord history with three horizontally scrollable charts:
/// - Scoring breakdown per game as stacked bars (FTs, 2Ps, 3Ps) with an overlaid total points line
/// - Shooting percentages per game (FT%, FG%, 3P%)
/// - Box score counting stats per game (REB, AST, STL, BLK)
///
/// All charts share the same horizontal scroll position and visible domain length so they
/// stay aligned when panning. Records are plotted in chronological order by save date.
struct ChartView: View {
    @Environment(\.modelContext) private var modelContext
    /// Query all records sorted by date ascending for chronological plotting.
    @Query(sort: \PlayerRecord.date) var history: [PlayerRecord]
    
    /// Shared horizontal scroll position across all charts so they pan together.
    @State private var scrollPosition: Int = 0
    
    var body: some View {
        // Number of games shown in the visible X domain at once.
        let xDomain = 10;
        
        VStack {
            // 1) Scoring breakdown: stacked bars for FTs/2Ps/3Ps and a thin black line for total points.
            Chart {
                ForEach(history.enumerated(), id: \.offset) { index, game in
                    // Free throws (1-point makes)
                    BarMark(
                        x: .value("Game", index),
                        y: .value("Value", game.ones)
                    )
                    .foregroundStyle(by: .value("Metric", "FTs"))
                    
                    // 2-point field goals (scaled to points)
                    BarMark(
                        x: .value("Game", index),
                        y: .value("Value", 2 * game.twos)
                    )
                    .foregroundStyle(by: .value("Metric", "2Ps"))
                    
                    // 3-point field goals (scaled to points)
                    BarMark(
                        x: .value("Game", index),
                        y: .value("Value", 3 * game.threes),
                    )
                    .foregroundStyle(by: .value("Metric", "3Ps"))
                    
                    // Total points line (ones + 2*twos + 3*threes)
                    LineMark(
                        x: .value("Game", index),
                        y: .value("Value", game.points)
                    )
                    .foregroundStyle(Color(.label))
                    .lineStyle(StrokeStyle(lineWidth: 0.5))
                }
            }
            .chartForegroundStyleScale([
                "FTs": Color(red:0.67, green:0.82, blue:0.92),
                "2Ps": Color(red:0.39, green:0.59, blue:0.92),
                "3Ps": Color(red:0.0, green:0.0, blue:1.0)
            ])
            .chartYAxisLabel("PTS")
            .padding()
            
            // 2) Shooting percentages per game: FT%, FG% (2s+3s), and 3P%.
            Chart() {
                ForEach(history.enumerated(), id: \.offset) { index, game in
                    // Free throw percentage
                    LineMark(
                        x: .value("Game", index),
                        y: .value("Value", game.ftPercentage)
                    )
                    .foregroundStyle(by: .value("Metric", "FT%"))
                    
                    // Field goal percentage (2s + 3s)
                    LineMark(
                        x: .value("Game", index),
                        y: .value("Value", game.fgPercentage)
                    )
                    .foregroundStyle(by: .value("Metric", "FG%"))
                    
                    // 3-point percentage
                    LineMark(
                        x: .value("Game", index),
                        y: .value("Value", game.threePointPercentage),
                    )
                    .foregroundStyle(by: .value("Metric", "3P%"))
                    
                }
            }
            .chartForegroundStyleScale([
                "FT%": Color(red:0.67, green:0.82, blue:0.92),
                "FG%": Color(red:0.39, green:0.59, blue:0.92),
                "3P%": Color(red:0.0, green:0.0, blue:1.0)
            ])
            .chartYAxisLabel("%")
            .padding()
            
            // 3) Box score counting stats per game: rebounds, assists, steals, blocks.
            Chart() {
                ForEach(history.enumerated(), id: \.offset) { index, game in
                    LineMark(
                        x: .value("Game", index),
                        y: .value("Value", game.rebounds),
                    )
                    .foregroundStyle(by: .value("Metric", "REB"))
                    
                    LineMark(
                        x: .value("Game", index),
                        y: .value("Value", game.assists),
                    )
                    .foregroundStyle(by: .value("Metric", "AST"))
                    
                    LineMark(
                        x: .value("Game", index),
                        y: .value("Value", game.steals),
                    )
                    .foregroundStyle(by: .value("Metric", "STL"))
                    
                    LineMark(
                        x: .value("Game", index),
                        y: .value("Value", game.blocks),
                    )
                    .foregroundStyle(by: .value("Metric", "BLK"))
                }
            }
            .chartForegroundStyleScale([
                "AST": Color(.cyan),
                "REB": Color(.green),
                "STL": Color(.red),
                "BLK": Color(.orange)
            ])

            .padding()
        }
        .chartLegend(position: .bottom, alignment: .center)
        .chartXAxisLabel("Game")
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: xDomain)
        .chartScrollPosition(x: $scrollPosition)
        
    }
}
