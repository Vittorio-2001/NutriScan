//
//  ScanView.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 16/11/25.
//

import SwiftUI

struct ScanView: View {
    
    @Binding var recipes: [Recipe]
    @Binding var history: [HistoryItem]
    
    @State private var isScanning = true
    @State private var isProcessingScan = false
    @State private var scannedProduct: ScannedProduct?
    
    var body: some View {
        ZStack {
            
            BarcodeScannerView(isScanning: $isScanning) { code in
                handleScan(code)
            }
            .ignoresSafeArea()
            
            VStack {
                Text("Scan a barcode")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                Spacer()
            }
        }
        .sheet(item: $scannedProduct, onDismiss: {
            isScanning = true
            isProcessingScan = false
        }) { product in
            ProductBottomSheet(product: product, recipes: recipes)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
    
    private func handleScan(_ code: String) {
        guard !isProcessingScan else { return }
        isProcessingScan = true
        isScanning = false
        
        HapticManager.success()
        
        Task {
            if let offProd = try? await OpenFoodFactsService.fetchProduct(barcode: code) {
                
                let nutr = offProd.nutriments
                
                let product = ScannedProduct(
                    barcode: code,
                    name: offProd.product_name ?? "Unknown product",
                    brand: offProd.brands ?? "Unknown brand",
                    imageURL: offProd.image_url,
                    calories: nutr?.energy_kcal_100g ?? 0,
                    fats: nutr?.fat_100g ?? 0,
                    sugars: nutr?.sugars_100g ?? 0,
                    proteins: nutr?.proteins_100g ?? 0
                )
                
                history.append(HistoryItem(product: product, date: Date()))
                scannedProduct = product
                
            } else {
                let product = ScannedProduct(
                    barcode: code,
                    name: "Product not found",
                    brand: "Unknown",
                    imageURL: nil,
                    calories: 0,
                    fats: 0,
                    sugars: 0,
                    proteins: 0
                )
                history.append(HistoryItem(product: product, date: Date()))
                scannedProduct = product
            }
        }
    }
}
