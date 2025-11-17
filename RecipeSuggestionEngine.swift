//
//  RecipeSuggestionEngine.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 17/11/25.
//

import Foundation

struct RecipeSuggestionEngine {
    
    static func suggestedRecipes(for product: ScannedProduct, from allRecipes: [Recipe]) -> [Recipe] {
        
        let productName = product.name.lowercased()
        
        let productKeywords = extractKeywords(from: productName)
        let mappedCategory = mapCategory(from: productName)
        
        // Step 1: Scoring
        let scored = allRecipes.map { recipe in
            let score = scoreRecipe(recipe,
                                    productKeywords: productKeywords,
                                    mappedCategory: mappedCategory)
            return (recipe, score)
        }
        
        // Step 2: eliminiamo le ricette completamente irrilevanti
        let filtered = scored.filter { $0.1 >= 8 }   // punteggio minimo 8
        
        // Step 3: ordiniamo per punteggio
        let sorted = filtered.sorted { $0.1 > $1.1 }
        
        // Step 4: restituiamo SOLO le prime 1-2
        return Array(sorted.prefix(2)).map { $0.0 }
    }
    
    
    // MARK: - SCORING
    
    private static func scoreRecipe(_ recipe: Recipe,
                                    productKeywords: [String],
                                    mappedCategory: String?) -> Int {
        
        var score = 0
        
        let name = recipe.name.lowercased()
        let cat = recipe.category.lowercased()
        
        // 1) Match nome ricetta
        for key in productKeywords {
            if name.contains(key) { score += 8 }
        }
        
        // 2) Match categoria mappata
        if let mapped = mappedCategory {
            if cat.contains(mapped.lowercased()) { score += 10 }
        }
        
        // 3) Casi speciali
        if mappedCategory == "Healthy" && cat.contains("healthy") {
            score += 12
        }
        
        if mappedCategory == "Snack" && cat.contains("snack") {
            score += 12
        }
        
        // 4) Bonus minimo per variare
        score += Int.random(in: 0...1)
        
        return score
    }
    
    
    // MARK: - KEYWORDS EXTRACTOR
    
    private static func extractKeywords(from name: String) -> [String] {
        
        let blacklist = ["the", "and", "with", "taste", "original", "fresh"]
        
        return name
            .replacingOccurrences(of: "-", with: " ")
            .split(separator: " ")
            .map { String($0).lowercased() }
            .filter { !blacklist.contains($0) && $0.count > 2 }
    }
    
    
    // MARK: - CATEGORY MAPPING
    
    private static func mapCategory(from name: String) -> String? {
        
        let n = name.lowercased()
        
        if n.contains("insalata") || n.contains("salad") {
            return "Healthy"
        }
        if n.contains("pasta") || n.contains("barilla") {
            return "Pasta"
        }
        if n.contains("chips") || n.contains("snack") || n.contains("pringles") {
            return "Snack"
        }
        if n.contains("yogurt") {
            return "Breakfast"
        }
        
        return nil
    }
}
