//
//  HistoryRow.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 17/11/25.
//


import SwiftUI

struct HistoryRow: View {

    let item: HistoryItem

    private var product: ScannedProduct { item.product }

    private var timeLabel: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: item.date)
    }

    var body: some View {
        HStack(spacing: 14) {

            // Thumbnail prodotto
            Group {
                if let urlStr = product.imageURL,
                   let url = URL(string: urlStr) {
                    AsyncImage(url: url) { img in
                        img.resizable().scaledToFill()
                    } placeholder: {
                        Color(.systemGray5)
                    }
                } else {
                    Color(.systemGray5)
                        .overlay(
                            Image(systemName: "barcode.viewfinder")
                                .foregroundColor(.secondary)
                        )
                }
            }
            .frame(width: 54, height: 54)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                Text(product.brand)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Text("\(Int(product.calories)) kcal · \(timeLabel)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Score circle
            ZStack {
                Circle()
                    .fill(scoreColor(product.score))
                    .frame(width: 40, height: 40)
                Text("\(product.score)")
                    .font(.caption.bold())
                    .foregroundColor(.white)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Helpers

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 75...100: return .green
        case 50..<75:  return Color.yellow.opacity(0.9)
        default:       return .red
        }
    }
}
