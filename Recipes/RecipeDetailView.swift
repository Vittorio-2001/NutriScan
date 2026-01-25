//
//  RecipeDetailView.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 16/11/25.
//


import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                
                // Immagine
                if UIImage(named: recipe.name) != nil {
                    Image(recipe.name)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 230)
                        .clipped()
                        .cornerRadius(16)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                }
                
                // Riga info con emoji
                HStack(spacing: 16) {
                    Text("⏱ \(recipe.prepTime) min")
                    Text("🔥 \(recipe.calories) kcal")
                    Text("📊 \(recipe.difficulty)")
                    Text("🏷 \(recipe.category)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                // Ingredients
                Text("Ingredients")
                    .font(.headline)
                
                ForEach(recipe.ingredients, id: \.self) { ing in
                    Text("• \(ing)")
                        .font(.subheadline)
                }
                
                // Steps
                Text("Steps")
                    .font(.headline)
                    .padding(.top, 8)
                
                ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1).")
                            .bold()
                        Text(step)
                    }
                    .font(.subheadline)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

