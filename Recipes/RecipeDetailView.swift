//
//  RecipeDetailView.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 16/11/25.
//


import SwiftUI

struct RecipeDetailView: View {

    let recipe: Recipe
    @State private var isFavorite: Bool

    init(recipe: Recipe) {
        self.recipe = recipe
        _isFavorite = State(initialValue: recipe.isFavorite)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // ── Immagine ─────────────────────────────────────────
                recipeImage
                    .frame(height: 240)
                    .clipped()

                VStack(alignment: .leading, spacing: 20) {

                    // Info pill
                    HStack(spacing: 12) {
                        infoPill(icon: "clock", text: "\(recipe.prepTime) min")
                        infoPill(icon: "flame", text: "\(recipe.calories) kcal")
                        infoPill(icon: "chart.bar", text: recipe.difficulty)
                        Spacer()
                    }

                    Divider()

                    // Ingredienti
                    if !recipe.ingredients.isEmpty {
                        Text("Ingredients")
                            .font(.headline)
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(recipe.ingredients, id: \.self) { ingredient in
                                Label(ingredient, systemImage: "circle.fill")
                                    .font(.subheadline)
                                    .labelStyle(SpacedLabelStyle())
                            }
                        }
                    }

                    Divider()

                    // Steps
                    if !recipe.steps.isEmpty {
                        Text("Steps")
                            .font(.headline)
                        VStack(alignment: .leading, spacing: 14) {
                            ForEach(Array(recipe.steps.enumerated()), id: \.offset) { i, step in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(i + 1)")
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                        .frame(width: 24, height: 24)
                                        .background(Color.green)
                                        .clipShape(Circle())
                                    Text(step)
                                        .font(.subheadline)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isFavorite.toggle()
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .secondary)
                }
            }
        }
    }

    // MARK: - Image (FIX)

    @ViewBuilder
    private var recipeImage: some View {
        // 1. Prova imageData (foto scattata dall'utente)
        if let data = recipe.imageData,
           let uiImg = UIImage(data: data) {
            Image(uiImage: uiImg)
                .resizable()
                .scaledToFill()

        // 2. Prova imageName nell'asset catalog (ricette demo)
        } else if let uiImg = UIImage(named: recipe.imageName ?? "") {
            Image(uiImage: uiImg)
                .resizable()
                .scaledToFill()

        // 3. Placeholder
        } else {
            Rectangle()
                .fill(Color(.systemGray5))
                .overlay(
                    Image(systemName: "fork.knife.circle")
                        .font(.system(size: 52))
                        .foregroundColor(.secondary.opacity(0.4))
                )
        }
    }

    // MARK: - Helpers

    private func infoPill(icon: String, text: String) -> some View {
        Label(text, systemImage: icon)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(20)
    }
}

// LabelStyle che aggiunge spazio tra icona e testo
private struct SpacedLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            configuration.icon
                .font(.system(size: 6))
                .foregroundColor(.green)
            configuration.title
        }
    }
}
