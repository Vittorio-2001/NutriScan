//
//  OpenFoodFactsService.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 16/11/25.
//

import Foundation

// MARK: - Full OFF Response

struct OFFProductResponse: Codable {
    let product: OFFProduct?
}

struct OFFProduct: Codable {
    let product_name: String?
    let brands: String?
    let image_url: String?
    let nutriments: OFFNutriments?
}

// MARK: - Nutriments con CodingKeys custom

struct OFFNutriments: Codable {

    let energyKcal100g: Double?   // "energy-kcal_100g"
    let energy100g:     Double?   // "energy_100g" in kJ (fallback)
    let fat100g:        Double?   // "fat_100g"
    let sugars100g:     Double?   // "sugars_100g"
    let proteins100g:   Double?   // "proteins_100g"

    enum CodingKeys: String, CodingKey {
        case energyKcal100g = "energy-kcal_100g"   // ← trattino nel JSON reale
        case energy100g     = "energy_100g"
        case fat100g        = "fat_100g"
        case sugars100g     = "sugars_100g"
        case proteins100g   = "proteins_100g"
    }

    /// Restituisce le kcal: prima prova il campo diretto,
    /// poi converte i kJ se disponibili (1 kcal ≈ 4.184 kJ).
    var kcalPer100g: Double {
        if let kcal = energyKcal100g, kcal > 0 { return kcal }
        if let kj   = energy100g,    kj   > 0  { return kj / 4.184 }
        return 0
    }
}

// MARK: - Service

class OpenFoodFactsService {

    static func fetchProduct(barcode: String) async throws -> OFFProduct? {
        let urlString = "https://world.openfoodfacts.org/api/v2/product/\(barcode).json"
        guard let url = URL(string: urlString) else { return nil }

        let (data, _) = try await URLSession.shared.data(from: url)

        let decoded = try JSONDecoder().decode(OFFProductResponse.self, from: data)
        return decoded.product
    }
}
