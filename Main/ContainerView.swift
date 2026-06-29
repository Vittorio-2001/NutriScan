//
//  ContainerView.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 16/11/25.
//

import SwiftUI

struct ContainerView: View {

    @State private var recipes: [Recipe]    = RecipeStorage.load()
    @State private var history: [HistoryItem] = HistoryStorage.load()

    var body: some View {
        TabView {
            ScanView(recipes: $recipes, history: $history)
                .tabItem {
                    Label("Scan", systemImage: "camera.viewfinder")
                }

            RecipesView(recipes: $recipes)
                .tabItem {
                    Label("Recipes", systemImage: "fork.knife")
                }

            HistoryView(history: $history)
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
        }

        .onChange(of: recipes) { newValue in
            RecipeStorage.save(newValue)
        }
    }
}
