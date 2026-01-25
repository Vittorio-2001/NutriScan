//
//  RecipeStorage.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 17/11/25.
//


import Foundation

struct RecipeStorage {
    static let key = "saved_recipes"
    
    static func save(_ recipes: [Recipe]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(recipes) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    static func load() -> [Recipe] {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? decoder.decode([Recipe].self, from: data) {
            return decoded
        }
        return loadInitialRecipes() // se non ci sono ricette salvate, usa le demo
    }
}