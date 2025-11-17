//
//  RecipeCardView.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 16/11/25.
//


import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.gray.opacity(0.15))
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 36, weight: .regular))
                        .foregroundColor(.secondary)
                )
                .frame(height: 160)
            
            Text(recipe.category)
                .font(.caption)
                .foregroundColor(.green)
            
            HStack {
                Label("\(recipe.prepTime) min", systemImage: "clock")
                Spacer()
                Label("\(recipe.calories) kcal", systemImage: "flame")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 3)
    }
}

