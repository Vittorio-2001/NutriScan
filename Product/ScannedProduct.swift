//
//  ScannedProduct.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 16/11/25.
//

import Foundation

struct ScannedProduct: Identifiable, Equatable, Codable {

    let id: UUID          
    let barcode: String
    let name: String
    let brand: String
    let imageURL: String?
    let calories: Double
    let fats: Double
    let sugars: Double
    let proteins: Double

    init(
        id: UUID = UUID(),
        barcode: String,
        name: String,
        brand: String,
        imageURL: String?,
        calories: Double,
        fats: Double,
        sugars: Double,
        proteins: Double
    ) {
        self.id       = id
        self.barcode  = barcode
        self.name     = name
        self.brand    = brand
        self.imageURL = imageURL
        self.calories = calories
        self.fats     = fats
        self.sugars   = sugars
        self.proteins = proteins
    }

    // Valutazione nutrizionale 1–100 (stile Yuka)
    var score: Int {
        let sugarPenalty   = min(sugars   * 3,    30)   // max 30 punti
        let fatPenalty     = min(fats     * 2,    30)   // max 30 punti
        let caloriePenalty = min(calories / 10,   40)   // max 40 punti

        let raw = 100 - Int(sugarPenalty + fatPenalty + caloriePenalty)
        return max(min(raw, 100), 1)
    }
}
