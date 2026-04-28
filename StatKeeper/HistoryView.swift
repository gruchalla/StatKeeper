//
//  HistoryView.swift
//  StatKeeper
//
//  Created by Kenny Gruchalla on 4/27/26.
//
import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PlayerRecord.date, order: .reverse) var history: [PlayerRecord]

    var body: some View {
        List{
            ForEach(history) { record in
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
                                Text("FTs").bold()
                                Text("2Ps").bold()
                                Text("3Ps").bold()
                            }
                            .padding(.vertical, 5)
                            
                            Divider()
                            
                            GridRow {
                                Text("\(record.points)")
                                Text("\(record.ftPercentage.formatted(.percent.precision(.fractionLength(0))))")
                                Text("\(record.fgPercentage.formatted(.percent.precision(.fractionLength(0))))")
                                Text("\(record.threePointPercentage.formatted(.percent.precision(.fractionLength(0))))")
                                Text("\(record.rebounds)")
                                Text("\(record.assists)")
                                Text("\(record.steals)")
                                Text("\(record.blocks)")
                                Text("\(record.minutesIn)")
                                Text("\(record.ones)/\(record.freeThrowAttempts)")
                                Text("\(record.twos)/\(record.twoPointAttempts)")
                                Text("\(record.threes)/\(record.threePointAttempts)")
                            }
                        }
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    modelContext.delete(record)
                                    Feedback.deleteWithSound()
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button(role: .cancel) {
                                    UIPasteboard.general.string = record.prettyPrint()
                                    Feedback.copied()
                                } label: {
                                    Label("Copy", systemImage: "doc.on.doc")
                                }
                            }



            }
        }
    }
}
