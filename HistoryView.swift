//
//  HistoryView.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 16/11/25.
//


import SwiftUI

struct HistoryView: View {
    
    @Binding var history: [HistoryItem]
    
    @State private var showClearAlert = false
    
    var body: some View {
        NavigationView {
            Group {
                if history.isEmpty {
                    
                    // EMPTY STATE
                    VStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 44))
                            .foregroundColor(.gray.opacity(0.7))
                        
                        Text("No scanned products yet")
                            .font(.title3.bold())
                            .foregroundColor(.primary)
                        
                        Text("Start scanning items and they will appear here.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                    
                } else {
                    
                    // LISTA HISTORY
                    List(history.sorted(by: { $0.date > $1.date })) { item in
                        NavigationLink {
                            HistoryProductDetailView(item: item)
                        } label: {
                            HStack(spacing: 12) {
                                
                                if let urlString = item.product.imageURL, let url = URL(string: urlString) {
                                    AsyncImage(url: url) { img in
                                        img.resizable().scaledToFill()
                                    } placeholder: {
                                        Color.gray.opacity(0.2)
                                    }
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                } else {
                                    Color.gray.opacity(0.2)
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.product.name)
                                        .font(.headline)
                                    Text(item.product.brand)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(item.date, style: .date)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("History")
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !history.isEmpty {
                        Button(role: .destructive) {
                            showClearAlert = true
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
            
            .alert("Clear History",
                   isPresented: $showClearAlert,
                   actions: {
                Button("Cancel", role: .cancel) {}
                Button("Delete All", role: .destructive) {
                    history.removeAll()
                }
            },
                   message: {
                Text("Are you sure you want to erase all scanned products?")
            })
        }
    }
}

