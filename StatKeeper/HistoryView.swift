//
//  HistoryView.swift
//  StatKeeper
//
//  Created by Kenny Gruchalla on 4/27/26.
//
import SwiftUI
import SwiftData

/// Displays a list of saved PlayerRecord entries, most recent first.
///
/// Each row shows the save date, notes, and a horizontally scrollable grid of key stats.
/// Swipe actions allow copying a summary or deleting a record.
struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    /// Query all records sorted by date descending.
    @Query(sort: \PlayerRecord.date, order: .reverse) var history: [PlayerRecord]

    @State private var showDeleteAlert = false
    @State private var recordToDelete: PlayerRecord?
    @State private var showEditAlert = false
    @State private var recordToEdit: PlayerRecord? = nil

    // Bindings from parent so we can set the record and switch tabs.
    @Binding var editingRecord: PlayerRecord?
    @Binding var selectedTab: Int
    
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
                            recordToDelete = record
                            showDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button(role: .cancel) {
                            recordToEdit = record
                            showEditAlert = true
                        } label: {
                            Label("Edit", systemImage: "square.and.pencil")
                        }
                    }
                }
            }
            .navigationTitle("Log")
            .accessibilityLabel(Text("History"))
            .alert("Are you sure?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    modelContext.delete(recordToDelete!)
                    Feedback.deleteWithSound()
                    showDeleteAlert = false
                }
                Button("Cancel", role: .cancel) {
                    showDeleteAlert = false
                }
            } message: {
                Text("Delete Record")
            }
            .accessibilityLabel(Text("Delete Record"))
            .alert("Are you sure?", isPresented: $showEditAlert) {
                Button("Edit", role: .destructive) {
                    // Set the record for editing and switch to Counters tab.
                    editingRecord = recordToEdit
                    selectedTab = 0
                    Feedback.copied()
                    showEditAlert = false
                }
                Button("Cancel", role: .cancel) {
                    showEditAlert = false
                }
            } message: {
                Text("Editing record clears current player state.")
            }
            .accessibilityLabel(Text("Edit Record"))
        }
}

