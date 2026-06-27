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

                // ── Immagine con badge favourite sovrapposto ──────────
                ZStack(alignment: .topLeading) {
                    recipeImage

                    // Badge cuore (visibile solo se isFavorite)
                    if recipe.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.red)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                            )
                            .padding(12)
                            .transition(.scale.combined(with: .opacity))
                    }
                }

                // ── Nome ricetta ──────────────────────────────────────
                Text(recipe.name)
                    .font(.title3.bold())
                    .lineLimit(2)
                    .foregroundColor(.primary)

                // ── Info ─────────────────────────────────────────────
                HStack(spacing: 12) {
                    Label("\(recipe.prepTime) min", systemImage: "clock")
                    Label("\(recipe.calories) kcal", systemImage: "flame")
                    Label(recipe.category, systemImage: "tag")
                    Label(recipe.difficulty, systemImage: "chart.bar")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(22)
            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)

            // ── Checkmark selezione multipla ──────────────────────────
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                    .padding(18)
            }
        }
    }

    // MARK: - Immagine

    @ViewBuilder
    private var recipeImage: some View {
        Group {
            if let data = recipe.imageData,
               let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
            } else {
                // Placeholder con gradient e icona
                LinearGradient(
                    colors: [Color.green.opacity(0.3), Color.teal.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(
                    Image(systemName: "fork.knife.circle")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.6))
                )
            }
        }
        .frame(height: 220)
        .clipped()
        .cornerRadius(16)
    }
}
