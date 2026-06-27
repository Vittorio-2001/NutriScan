//
//  HistoryProductDetailView.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 16/11/25.
//

import SwiftUI

struct HistoryProductDetailView: View {

    let item: HistoryItem
    @Environment(\.dismiss) private var dismiss

    private var product: ScannedProduct { item.product }

    private var dateLabel: String {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .short
        return f.string(from: item.date)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Immagine
                if let urlStr = product.imageURL,
                   let url = URL(string: urlStr) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView().frame(height: 200)
                    }
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(16)
                }

                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text(product.name)
                        .font(.title2.bold())
                    Text(product.brand)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Scanned on \(dateLabel)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Score banner
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Nutritional score")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.85))
                        Text("\(product.score) / 100")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Image(systemName: scoreIcon(product.score))
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }
                .padding()
                .background(scoreColor(product.score).gradient)
                .cornerRadius(14)

                // Nutritional values
                Text("Nutritional values (per 100g)")
                    .font(.headline)

                VStack(spacing: 10) {
                    // FIX: Int(calories) per le kcal, %.1f per i grammi
                    nutrientRow(icon: "flame.fill",      color: .orange, label: "Calories",  value: "\(Int(product.calories)) kcal")
                    nutrientRow(icon: "cube.fill",       color: .blue,   label: "Sugars",    value: String(format: "%.1f g", product.sugars))
                    nutrientRow(icon: "drop.fill",       color: .yellow, label: "Fat",       value: String(format: "%.1f g", product.fats))
                    nutrientRow(icon: "bolt.heart.fill", color: .red,    label: "Proteins",  value: String(format: "%.1f g", product.proteins))
                }
            }
            .padding()
        }
        .navigationTitle("Product Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
    }

    // MARK: - Helpers

    private func nutrientRow(icon: String, color: Color, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 28)
            Text(label)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 75...100: return .green
        case 50..<75:  return .yellow
        default:       return .red
        }
    }

    private func scoreIcon(_ score: Int) -> String {
        switch score {
        case 75...100: return "checkmark.seal.fill"
        case 50..<75:  return "exclamationmark.triangle.fill"
        default:       return "xmark.octagon.fill"
        }
    }
}
