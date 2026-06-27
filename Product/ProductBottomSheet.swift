//
//  ProductBottomSheet.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 16/11/25.
//


import SwiftUI

struct ProductBottomSheet: View {

    let product: ScannedProduct
    let recipes: [Recipe]

    @State private var selectedRecipe: Recipe? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {

                // Immagine prodotto
                if let urlStr = product.imageURL,
                   let url = URL(string: urlStr) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                            .frame(height: 220)
                    }
                    .frame(height: 220)
                    .clipped()
                    .cornerRadius(16)
                }

                // Header: nome, brand, score
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.name)
                            .font(.title3.bold())
                        Text(product.brand)
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                    Spacer()
                    VStack {
                        Text("\(product.score)")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("/100")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(width: 52, height: 52)
                    .background(scoreColor(product.score))
                    .clipShape(Circle())
                }

                // Valori nutrizionali
                Text("Nutritional values (per 100g)")
                    .font(.headline)

                VStack(spacing: 10) {
                    nutrientRow(icon: "flame.fill",      label: "Calories",  value: "\(Int(product.calories)) kcal")
                    nutrientRow(icon: "cube.fill",       label: "Sugars",    value: String(format: "%.1f g", product.sugars))
                    nutrientRow(icon: "drop.fill",       label: "Fat",       value: String(format: "%.1f g", product.fats))
                    nutrientRow(icon: "bolt.heart.fill", label: "Proteins",  value: String(format: "%.1f g", product.proteins))
                }

                Divider().padding(.vertical, 8)

                // Suggested recipes
                Text("Suggested recipes")
                    .font(.headline)
                    .padding(.top, 8)

                let suggestions = RecipeSuggestionEngine.suggestedRecipes(for: product, from: recipes)

                if suggestions.isEmpty {
                    Text("No suggestions available.")
                        .foregroundColor(.secondary)
                } else {
                    VStack(spacing: 12) {
                        ForEach(suggestions) { recipe in
                            Button {
                                selectedRecipe = recipe
                            } label: {
                                RecipeCardView(recipe: recipe)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding()
        }
        // FIX: sheet era dentro un Group extra con una } in più che rompeva la struct
        .sheet(item: $selectedRecipe) { recipe in
            NavigationView {
                RecipeDetailView(recipe: recipe)
            }
        }
    }

    // MARK: - Helpers (ora correttamente DENTRO la struct)

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 75...100: return .green
        case 50..<75:  return .yellow
        default:       return .red
        }
    }

    private func nutrientRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 24)
            Text(label)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}
