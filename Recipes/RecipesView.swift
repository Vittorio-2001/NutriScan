//
//  RecipesView.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 16/11/25.
//

import SwiftUI

struct RecipesView: View {
    
    @Binding var recipes: [Recipe]
    
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    
    @State private var showAddSheet = false
    
    enum SortType: String, CaseIterable {
        case none = "None"
        case calories = "Calories"
        case prepTime = "Prep time"
        case alphabetical = "Alphabetical"
    }
    
    @State private var sortType: SortType = .none
    
    @State private var selectionMode = false
    @State private var selectedIDs = Set<String>()
    
    let categories = ["All", "Pasta", "Healthy", "Snack", "Breakfast", "Dessert", "Other"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    searchBar
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    categoryScroll
                        .padding(.leading)
                    
                    VStack(spacing: 20) {
                        ForEach(filteredAndSortedRecipes) { recipe in
                            
                            if selectionMode {
                                RecipeCroutonCard(
                                    recipe: recipe,
                                    isSelected: selectedIDs.contains(recipe.id)
                                )
                                .onTapGesture {
                                    toggleSelection(for: recipe)
                                }
                            } else {
                                NavigationLink {
                                    RecipeDetailView(recipe: recipe)
                                } label: {
                                    RecipeCroutonCard(recipe: recipe)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Recipes")
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        
                        Menu {
                            ForEach(SortType.allCases, id: \.self) { type in
                                Button {
                                    sortType = type
                                } label: {
                                    if sortType == type {
                                        Label(type.rawValue, systemImage: "checkmark")
                                    } else {
                                        Text(type.rawValue)
                                    }
                                }
                            }
                        } label: {
                            Label("Sort by", systemImage: "arrow.up.arrow.down")
                        }
                        
                        Button {
                            toggleSelectionMode()
                        } label: {
                            Label(
                                selectionMode ? "Cancel selection" : "Select multiple",
                                systemImage: selectionMode ? "xmark.circle" : "checkmark.circle"
                            )
                        }
                        
                        if selectionMode && !selectedIDs.isEmpty {
                            Button(role: .destructive) {
                                deleteSelected()
                            } label: {
                                Label("Delete selected (\(selectedIDs.count))", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            RecipeFormView(recipes: $recipes)
        }
    }
    
    private var filteredAndSortedRecipes: [Recipe] {
        var list = recipes
        
        if !searchText.isEmpty {
            list = list.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let cat = selectedCategory, cat != "All" {
            list = list.filter { $0.category == cat }
        }
        
        switch sortType {
        case .none:
            break
        case .calories:
            list = list.sorted { $0.calories < $1.calories }
        case .prepTime:
            list = list.sorted { $0.prepTime < $1.prepTime }
        case .alphabetical:
            list = list.sorted { $0.name < $1.name }
        }
        
        return list
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            TextField("Search recipes…", text: $searchText)
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
    
    private var categoryScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { cat in
                    Button {
                        selectedCategory = (cat == "All") ? nil : cat
                    } label: {
                        let active = selectedCategory == cat || (cat == "All" && selectedCategory == nil)
                        Text(cat)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 14)
                            .background(active ? Color.blue.opacity(0.9) : Color.gray.opacity(0.2))
                            .foregroundColor(active ? .white : .primary)
                            .cornerRadius(22)
                    }
                }
            }
            .padding(.vertical, 6)
        }
    }
    
    private func toggleSelection(for recipe: Recipe) {
        if selectedIDs.contains(recipe.id) {
            selectedIDs.remove(recipe.id)
        } else {
            selectedIDs.insert(recipe.id)
        }
    }
    
    private func toggleSelectionMode() {
        selectionMode.toggle()
        if !selectionMode { selectedIDs.removeAll() }
    }
    
    private func deleteSelected() {
        recipes.removeAll { selectedIDs.contains($0.id) }
        selectedIDs.removeAll()
        selectionMode = false
    }
}
