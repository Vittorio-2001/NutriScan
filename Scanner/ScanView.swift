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

    @State private var isScanning        = true
    @State private var isProcessingScan  = false
    @State private var scannedProduct: ScannedProduct?
    @State private var showErrorBanner   = false
    @State private var reticlePulse      = false

    private let reticleSize: CGFloat = 260

    var body: some View {
        ZStack {

            // ── Camera (full screen) ─────────────────────────────────
            BarcodeScannerView(isScanning: $isScanning) { code in
                handleScan(code)
            }
            .ignoresSafeArea()

            // ── Overlay: 4 rettangoli scuri + reticolo centrato ──────
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let s = reticleSize
                let x0 = (w - s) / 2
                let y0 = (h - s) / 2

                ZStack {
                    // Pannelli scuri attorno al reticolo
                    // Top
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                        .frame(width: w, height: y0)
                        .position(x: w / 2, y: y0 / 2)

                    // Bottom
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                        .frame(width: w, height: h - y0 - s)
                        .position(x: w / 2, y: y0 + s + (h - y0 - s) / 2)

                    // Left
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                        .frame(width: x0, height: s)
                        .position(x: x0 / 2, y: y0 + s / 2)

                    // Right
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                        .frame(width: w - x0 - s, height: s)
                        .position(x: x0 + s + (w - x0 - s) / 2, y: y0 + s / 2)

                    // Bracket angolari
                    CornerBrackets()
                        .stroke(
                            reticlePulse ? Color.green : Color.white,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: s, height: s)
                        .position(x: w / 2, y: h / 2)
                        .animation(
                            .easeInOut(duration: 1.1).repeatForever(autoreverses: true),
                            value: reticlePulse
                        )
                }
            }
            .ignoresSafeArea()   // ← usa l'intera dimensione schermo, safe area inclusa

            // ── UI sopra l'overlay ───────────────────────────────────
            VStack(spacing: 0) {

                // Label superiore in safe area
                Text(isProcessingScan ? "Searching…" : "Center the barcode")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.top, 16)

                Spacer()

                // Banner errore (in basso)
                if showErrorBanner {
                    Text("Product not found — try again")
                        .font(.footnote.weight(.medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.85))
                        .clipShape(Capsule())
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 24)
                }
            }
        }
        .onAppear { reticlePulse = true }
        .sheet(item: $scannedProduct, onDismiss: {
            isScanning       = true
            isProcessingScan = false
            showErrorBanner  = false
        }) { product in
            ProductBottomSheet(product: product, recipes: recipes)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Scan handler

    private func handleScan(_ code: String) {
        guard !isProcessingScan else { return }
        isProcessingScan = true
        isScanning = false
        HapticManager.success()

        Task {
            if let offProd = try? await OpenFoodFactsService.fetchProduct(barcode: code) {
                let nutr = offProd.nutriments
                let product = ScannedProduct(
                    barcode:  code,
                    name:     offProd.product_name ?? "Unknown product",
                    brand:    offProd.brands       ?? "Unknown brand",
                    imageURL: offProd.image_url,
                    calories: nutr?.kcalPer100g    ?? 0,
                    fats:     nutr?.fat100g        ?? 0,
                    sugars:   nutr?.sugars100g     ?? 0,
                    proteins: nutr?.proteins100g   ?? 0
                )
                await MainActor.run {
                    history.append(HistoryItem(product: product, date: Date()))
                    scannedProduct = product
                }
            } else {
                await MainActor.run {
                    withAnimation { showErrorBanner = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation { showErrorBanner = false }
                        isScanning       = true
                        isProcessingScan = false
                    }
                }
            }
        }
    }
}

// MARK: - Corner brackets shape

private struct CornerBrackets: Shape {
    func path(in rect: CGRect) -> Path {
        let len: CGFloat = 28
        var p = Path()
        // Top-left
        p.move(to: CGPoint(x: 0, y: len)); p.addLine(to: .zero); p.addLine(to: CGPoint(x: len, y: 0))
        // Top-right
        p.move(to: CGPoint(x: rect.maxX - len, y: 0)); p.addLine(to: CGPoint(x: rect.maxX, y: 0)); p.addLine(to: CGPoint(x: rect.maxX, y: len))
        // Bottom-right
        p.move(to: CGPoint(x: rect.maxX, y: rect.maxY - len)); p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)); p.addLine(to: CGPoint(x: rect.maxX - len, y: rect.maxY))
        // Bottom-left
        p.move(to: CGPoint(x: len, y: rect.maxY)); p.addLine(to: CGPoint(x: 0, y: rect.maxY)); p.addLine(to: CGPoint(x: 0, y: rect.maxY - len))
        return p
    }
}
