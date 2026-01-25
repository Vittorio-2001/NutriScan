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

// MARK: - Nutriments (kcal + kJ support)

struct OFFNutriments: Codable {
    let energy_kcal_100g: Double?     // kcal per 100g
    let energy_100g: Double?          // kJ per 100g (fallback)
    let fat_100g: Double?
    let sugars_100g: Double?
    let proteins_100g: Double?
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
