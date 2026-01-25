//
//  HistoryProductDetailView.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 16/11/25.
//

import SwiftUI

struct HistoryProductDetailView: View {
    
    let item: HistoryItem
    let recipes: [Recipe] = RecipeStorage.load()  // usiamo quelle salvate

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                
                // MARK: - Product Image (piccola come nel bottom sheet)
                if let imageURLString = item.product.imageURL, let url = URL(string: imageURLString) {
                    AsyncImage(url: url) { img in
                        img.resizable().scaledToFit()
                    } placeholder: {
                        Rectangle().fill(Color.gray.opacity(0.2))
                    }
                    .frame(maxWidth: 180, maxHeight: 180)
                    .cornerRadius(14)
                    .padding(.top, 20)
                } else {
                    // Fallback placeholder when there's no valid image URL
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(maxWidth: 180, maxHeight: 180)
                        .cornerRadius(14)
                        .padding(.top, 20)
                }
                
                // MARK: - Title + Brand
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.product.name)
                        .font(.title2.bold())
                    if !item.product.brand.isEmpty {
                        Text(item.product.brand)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // MARK: - Nutritional Values
                VStack(alignment: .leading, spacing: 12) {
                    Text("Nutritional values (per 100g)")
                        .font(.headline)
                    
                    HStack(spacing: 16) {
                        nutrientBox(title: "Calories", value: "\(item.product.calories) kcal")
                        nutrientBox(title: "Fats", value: "\(item.product.fats) g")
                        nutrientBox(title: "Sugars", value: "\(item.product.sugars) g")
                        nutrientBox(title: "Proteins", value: "\(item.product.proteins) g")
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // MARK: - Suggested Recipes
                VStack(alignment: .leading, spacing: 12) {
                    Text("Suggested recipes")
                        .font(.title3.bold())
                    
                    let suggested = aiSuggestedRecipes(for: item.product, from: recipes)
                    
                    if suggested.isEmpty {
                        Text("No recipes matched.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(suggested) { recipe in
                            NavigationLink {
                                RecipeDetailView(recipe: recipe)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(recipe.name)
                                            .font(.headline)
                                        Text(recipe.category)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationTitle("Product")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    // MARK: - Nutrient Mini Boxes
    func nutrientBox(title: String, value: String) -> some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    
    // MARK: - Suggested Recipes Logic
    func aiSuggestedRecipes(for product: ScannedProduct, from recipes: [Recipe]) -> [Recipe] {
        
        let nameWords = product.name.lowercased().split(separator: " ")
        
        // score recipes
        let scored = recipes.map { recipe -> (Recipe, Int) in
            var score = 0
            
            // match on ingredients
            for word in nameWords {
                if recipe.ingredients.joined().lowercased().contains(word) {
                    score += 4
                }
            }
            
            // match on recipe name
            for word in nameWords {
                if recipe.name.lowercased().contains(word) {
                    score += 6
                }
            }
            
            return (recipe, score)
        }
        
        // take the best 3
        return scored
            .sorted { $0.1 > $1.1 }
            .prefix(3)
            .map { $0.0 }
    }
}

