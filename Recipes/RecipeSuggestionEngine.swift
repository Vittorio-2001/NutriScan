//
//  RecipeSuggestionEngine.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 17/11/25.
//

import Foundation

struct RecipeSuggestionEngine {

    static func suggestedRecipes(for product: ScannedProduct, from recipes: [Recipe]) -> [Recipe] {
        let scored: [(Recipe, Int)] = recipes.map { recipe in
            let score = computeScore(product: product, recipe: recipe)
            return (recipe, score)
        }

        return scored
            .sorted { $0.1 > $1.1 }   // ordine decrescente deterministico
            .prefix(3)
            .map { $0.0 }
    }

    // MARK: - Scoring (deterministico)

    private static func computeScore(product: ScannedProduct, recipe: Recipe) -> Int {
        var score = 0

        // Prodotto proteico → preferisci ricette con carne/pesce
        if product.proteins > 15 {
            if recipe.category == "Meat" || recipe.category == "Fish" { score += 3 }
        }

        // Prodotto calorico → favorisci ricette light
        if product.calories > 400 {
            if recipe.category == "Salad" || recipe.category == "Healthy" { score += 3 }
            if recipe.calories < 300 { score += 2 }
        }

        // Poche calorie → ricette più elaborate
        if product.calories < 100 {
            if recipe.category == "Pasta" || recipe.category == "Soup" { score += 2 }
        }

        // Prodotto con molto zucchero → dessert o ricette semplici
        if product.sugars > 20 {
            if recipe.category == "Dessert" { score += 2 }
        }

        // Preferisci ricette veloci e semplici di default
        if recipe.prepTime <= 20 { score += 1 }
        if recipe.difficulty == "Easy" { score += 1 }

        // Ricette preferite in cima
        if recipe.isFavorite { score += 2 }

        return score
    }
}
