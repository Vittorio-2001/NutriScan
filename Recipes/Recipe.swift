//
//  Recipe.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 16/11/25.
//
import Foundation

struct Recipe: Identifiable, Equatable, Codable {
    let id: String
    var name: String
    var category: String
    var ingredients: [String]
    var steps: [String]
    var prepTime: Int
    var calories: Int
    var difficulty: String
    var imageData: Data?   
}

