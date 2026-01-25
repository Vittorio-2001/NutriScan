//
//  HistoryItem.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 16/11/25.
//


import Foundation

struct HistoryItem: Identifiable, Equatable, Codable {
    let id = UUID()
    let product: ScannedProduct
    let date: Date
}

