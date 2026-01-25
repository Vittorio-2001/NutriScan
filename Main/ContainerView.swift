//
//  ContainerView.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 16/11/25.
//

import SwiftUI

struct ContainerView: View {
    
    @State private var recipes: [Recipe] = RecipeStorage.load()
    
    @State private var history: [HistoryItem] = HistoryStorage.load()
    
    var body: some View {
        TabView {
            
            ScanView(recipes: $recipes, history: $history)
                .tabItem {
                    Image(systemName: "camera.viewfinder")
                    Text("Scan")
                }
            
            RecipesView(recipes: $recipes)
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Recipes")
                }
            
            HistoryView(history: $history)
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("History")
                }
        }
        
        // Salva ricette quando cambiano
        .onChange(of: recipes) { newValue in
            RecipeStorage.save(newValue)
        }
        
        // Salva history quando cambia
        .onChange(of: history) { newValue in
            HistoryStorage.save(newValue)
        }
    }
}
