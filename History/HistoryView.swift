//
//  HistoryView.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 16/11/25.
//


import SwiftUI

struct HistoryView: View {

    @Binding var history: [HistoryItem]
    @State private var showDeleteAllConfirm = false
    @State private var selectedItem: HistoryItem? = nil

    // Raggruppa per data (giorno)
    private var groupedHistory: [(String, [HistoryItem])] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        let grouped = Dictionary(grouping: history) { item in
            formatter.string(from: item.date)
        }

        return grouped
            .sorted { a, b in
                // ordine decrescente per data
                guard
                    let da = history.first(where: { formatter.string(from: $0.date) == a.key })?.date,
                    let db = history.first(where: { formatter.string(from: $0.date) == b.key })?.date
                else { return false }
                return da > db
            }
    }

    var body: some View {
        NavigationView {
            Group {
                if history.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(groupedHistory, id: \.0) { (dateLabel, items) in
                            Section(header: Text(dateLabel).font(.subheadline.bold())) {
                                ForEach(items) { item in
                                    Button {
                                        selectedItem = item
                                    } label: {
                                        // FIX: usa finalmente HistoryRow
                                        HistoryRow(item: item)
                                    }
                                    .buttonStyle(.plain)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                }
                                // FIX: swipe-to-delete singolo elemento
                                .onDelete { indexSet in
                                    deleteItems(in: items, at: indexSet)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("History")
            .toolbar {
                if !history.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(role: .destructive) {
                            showDeleteAllConfirm = true
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
            // FIX: confirmationDialog invece di cancellare subito
            .confirmationDialog(
                "Delete entire history?",
                isPresented: $showDeleteAllConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete all", role: .destructive) {
                    withAnimation { history.removeAll() }
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(item: $selectedItem) { item in
                NavigationView {
                    HistoryProductDetailView(item: item)
                }
            }
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 56))
                .foregroundColor(.secondary.opacity(0.5))
            Text("No scans yet")
                .font(.title3.bold())
            Text("Scanned products will appear here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - Delete

    private func deleteItems(in section: [HistoryItem], at offsets: IndexSet) {
        let toDelete = offsets.map { section[$0].id }
        withAnimation {
            history.removeAll { toDelete.contains($0.id) }
        }
    }
}
