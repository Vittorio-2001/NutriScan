//
//  Recipe.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 16/11/25.
//


import Foundation

struct Recipe: Identifiable, Codable, Equatable {

    let id:          String
    let name:        String
    let imageName:   String?   // ← ora optional (prima era String non-optional)
    let imageData:   Data?     // ← NUOVO: per le foto dell'utente
    let calories:    Int
    let prepTime:    Int
    let difficulty:  String
    let ingredients: [String]
    let steps:       [String]
    let category:    String
    var isFavorite:  Bool

    // CodingKeys per compatibilità con il JSON esistente
    // (imageData non esiste nei JSON vecchi → decodifica safely come nil)
    enum CodingKeys: String, CodingKey {
        case id, name, imageName, imageData,
             calories, prepTime, difficulty,
             ingredients, steps, category, isFavorite
    }

    init(
        id:          String   = UUID().uuidString,
        name:        String,
        imageName:   String?  = nil,
        imageData:   Data?    = nil,
        calories:    Int      = 0,
        prepTime:    Int      = 20,
        difficulty:  String   = "Easy",
        ingredients: [String] = [],
        steps:       [String] = [],
        category:    String   = "Other",
        isFavorite:  Bool     = false
    ) {
        self.id          = id
        self.name        = name
        self.imageName   = imageName
        self.imageData   = imageData
        self.calories    = calories
        self.prepTime    = prepTime
        self.difficulty  = difficulty
        self.ingredients = ingredients
        self.steps       = steps
        self.category    = category
        self.isFavorite  = isFavorite
    }
}
