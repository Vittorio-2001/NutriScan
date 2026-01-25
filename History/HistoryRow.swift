//
//  HistoryRow.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 17/11/25.
//


import SwiftUI

struct HistoryRow: View {
    
    let product: ScannedProduct
    let date: Date
    
    var body: some View {
        HStack(spacing: 12) {
            
            // Immagine prodotto
            if let urlStr = product.imageURL,
               let url = URL(string: urlStr) {
                AsyncImage(url: url) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 60, height: 60)
                .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 60, height: 60)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(product.brand)
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                    .lineLimit(1)
                
                Text(date.formatted(date: .abbreviated, time: .shortened))
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            
            Spacer()
            
            // Score stile Yuka
            VStack {
                Text("\(product.score)")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("/100")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(width: 50, height: 50)
            .background(scoreColor(product.score))
            .clipShape(Circle())
        }
        .padding(.vertical, 6)
    }
    
    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 75...100: return .green
        case 50..<75: return .yellow
        default: return .red
        }
    }
}
