//
//  RecipeCroutonCard.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 17/11/25.
//

import SwiftUI

struct RecipeCroutonCard: View {
    let recipe: Recipe
    var isSelected: Bool = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            VStack(alignment: .leading, spacing: 12) {
                
                if let data = recipe.imageData,
                   let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .clipped()
                        .cornerRadius(22)
                } else {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 220)
                }
                
                Text(recipe.name)
                    .font(.title3.bold())
                    .lineLimit(2)
                
                // Info con emoji
                HStack(spacing: 12) {
                    Text("⏱ \(recipe.prepTime) min")
                    Text("🔥 \(recipe.calories) kcal")
                    Text("🏷 \(recipe.category)")
                    Text("📊 \(recipe.difficulty)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(22)
            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                    .padding(18)
            }
        }
    }
}
