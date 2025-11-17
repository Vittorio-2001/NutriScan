//
//  ScannedProduct.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 16/11/25.
//

import Foundation

struct ScannedProduct: Identifiable, Equatable, Codable {
    let id = UUID()
    let barcode: String
    let name: String
    let brand: String
    let imageURL: String?
    let calories: Double
    let fats: Double
    let sugars: Double
    let proteins: Double
    
    // Valutazione nutrizionale 1–100 (semplificata stile Yuka)
    var score: Int {
        let sugarPenalty = min(sugars * 3, 30)     // max 30 punti
        let fatPenalty = min(fats * 2, 30)         // max 30 punti
        let caloriePenalty = min(calories / 10, 40) // max 40 punti
        
        let raw = 100 - Int(sugarPenalty + fatPenalty + caloriePenalty)
        return max(min(raw, 100), 1)
    }
}
