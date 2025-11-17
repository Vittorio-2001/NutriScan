//
//  LocalDatabase.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 16/11/25.
//

import Foundation

private let recipesUserDefaultsKey = "recipes_store_v1"

func loadDefaultRecipes() -> [Recipe] {
    guard let url = Bundle.main.url(forResource: "recipes", withExtension: "json") else {
        print("ERROR: recipes.json not found")
        return []
    }
    
    do {
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode([Recipe].self, from: data)
        return decoded
    } catch {
        print("ERROR decoding recipes.json:", error)
        return []
    }
}

func loadInitialRecipes() -> [Recipe] {
    let defaults = UserDefaults.standard
    if let data = defaults.data(forKey: recipesUserDefaultsKey),
       let decoded = try? JSONDecoder().decode([Recipe].self, from: data) {
        return decoded
    } else {
        let defaultsRecipes = loadDefaultRecipes()
        saveRecipes(defaultsRecipes)
        return defaultsRecipes
    }
}

func saveRecipes(_ recipes: [Recipe]) {
    let defaults = UserDefaults.standard
    if let data = try? JSONEncoder().encode(recipes) {
        defaults.set(data, forKey: recipesUserDefaultsKey)
    }
}
