//
//  RecipesView.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 16/11/25.
//

import SwiftUI

struct RecipesView: View {

    @Binding var recipes: [Recipe]

    @State private var searchText         = ""
    @State private var selectedCategory: String? = nil
    @State private var showAddSheet       = false
    @State private var recipeToEdit: Recipe?      = nil
    @State private var sortType: SortType         = .none
    @State private var selectionMode      = false
    @State private var selectedIDs        = Set<String>()

    enum SortType: String, CaseIterable {
        case none         = "None"
        case calories     = "Calories"
        case prepTime     = "Prep time"
        case alphabetical = "Alphabetical"
    }

    let categories = ["All", "Pasta", "Healthy", "Snack", "Breakfast", "Dessert", "Other"]

    // MARK: - Body

    var body: some View {
        NavigationView {
            Group {
                if recipes.isEmpty {
                    emptyState(
                        icon:     "fork.knife.circle",
                        title:    "No recipes yet",
                        subtitle: "Tap + to add your first recipe."
                    )
                } else {
                    let filtered = filteredAndSortedRecipes

                    // ── Header: search + category (in List section) ──
                    List {
                        // Sezione header (search + chip categorie)
                        Section {
                            searchBar
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)

                            categoryScroll
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }

                        // Sezione ricette
                        Section {
                            if filtered.isEmpty {
                                emptyState(
                                    icon:     "magnifyingglass",
                                    title:    "No results",
                                    subtitle: "Try a different search or category."
                                )
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            } else {
                                ForEach(filtered) { recipe in
                                    recipeRow(recipe)
                                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                        // ── Swipe trailing: Delete ───
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                withAnimation { deleteRecipe(recipe) }
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                        // ── Swipe leading: Edit + Favourite ──
                                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                            Button {
                                                recipeToEdit = recipe
                                            } label: {
                                                Label("Edit", systemImage: "pencil")
                                            }
                                            .tint(.blue)

                                            Button {
                                                toggleFavourite(recipe)
                                            } label: {
                                                Label(
                                                    recipe.isFavorite ? "Unfavourite" : "Favourite",
                                                    systemImage: recipe.isFavorite ? "heart.slash" : "heart.fill"
                                                )
                                            }
                                            .tint(.pink)
                                        }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Recipes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAddSheet = true } label: {
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

                        Button { toggleSelectionMode() } label: {
                            Label(
                                selectionMode ? "Cancel selection" : "Select multiple",
                                systemImage: selectionMode ? "xmark.circle" : "checkmark.circle"
                            )
                        }

                        if selectionMode && !selectedIDs.isEmpty {
                            Button(role: .destructive) { deleteSelected() } label: {
                                Label("Delete selected (\(selectedIDs.count))", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        // Crea nuova ricetta
        .sheet(isPresented: $showAddSheet) {
            RecipeFormView(recipes: $recipes)
        }
        // Modifica ricetta esistente
        .sheet(item: $recipeToEdit) { recipe in
            RecipeFormView(recipes: $recipes, editingRecipe: recipe)
        }
    }

    // MARK: - Row builder

    @ViewBuilder
    private func recipeRow(_ recipe: Recipe) -> some View {
        if selectionMode {
            RecipeCroutonCard(recipe: recipe, isSelected: selectedIDs.contains(recipe.id))
                .onTapGesture { toggleSelection(for: recipe) }
        } else {
            // NavigationLink nascosto (opacity 0) → nessun chevron visibile
            ZStack {
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) { EmptyView() }
                    .opacity(0)
                RecipeCroutonCard(recipe: recipe)
            }
        }
    }

    // MARK: - Empty state

    private func emptyState(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundColor(.secondary.opacity(0.45))
            Text(title)
                .font(.title3.bold())
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    // MARK: - Filtering & sorting

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
        case .none:         break
        case .calories:     list = list.sorted { $0.calories < $1.calories }
        case .prepTime:     list = list.sorted { $0.prepTime < $1.prepTime }
        case .alphabetical: list = list.sorted { $0.name < $1.name }
        }

        return list
    }

    // MARK: - Subviews

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
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
    }

    // MARK: - Actions

    private func deleteRecipe(_ recipe: Recipe) {
        recipes.removeAll { $0.id == recipe.id }
    }

    private func toggleFavourite(_ recipe: Recipe) {
        guard let idx = recipes.firstIndex(where: { $0.id == recipe.id }) else { return }
        recipes[idx] = Recipe(
            id:          recipe.id,
            name:        recipe.name,
            imageName:   recipe.imageName,
            imageData:   recipe.imageData,
            calories:    recipe.calories,
            prepTime:    recipe.prepTime,
            difficulty:  recipe.difficulty,
            ingredients: recipe.ingredients,
            steps:       recipe.steps,
            category:    recipe.category,
            isFavorite:  !recipe.isFavorite
        )
        RecipeStorage.save(recipes)
    }

    private func toggleSelection(for recipe: Recipe) {
        if selectedIDs.contains(recipe.id) { selectedIDs.remove(recipe.id) }
        else { selectedIDs.insert(recipe.id) }
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
