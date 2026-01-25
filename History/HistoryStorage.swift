//
//  HistoryStorage.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 17/11/25.
//


import Foundation

struct HistoryStorage {
    static let key = "saved_history"
    
    static func save(_ history: [HistoryItem]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(history) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    static func load() -> [HistoryItem] {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? decoder.decode([HistoryItem].self, from: data) {
            return decoded
        }
        return []
    }
}
