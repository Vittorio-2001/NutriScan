//
//  RecipeFormView.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 16/11/25.
//

import SwiftUI
import PhotosUI

struct RecipeFormView: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var recipes: [Recipe]
    
    @State private var title = ""
    @State private var category = "Other"
    @State private var prepTime = 10
    @State private var calories = 200
    @State private var difficulty = "Easy"
    
    @State private var ingredients: [String] = [""]
    @State private var steps: [String] = [""]
    
    // MARK: - PHOTO PICKER
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var pickedImageData: Data? = nil
    
    let categories = ["Pasta", "Healthy", "Snack", "Breakfast", "Dessert", "Other"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    
                    
                    // MARK: PHOTO PICKER (Crouton style)
                    VStack {
                        if let data = pickedImageData,
                           let uiImage = UIImage(data: data) {
                            
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 220)
                                .clipped()
                                .cornerRadius(16)
                            
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemGray6))
                                    .frame(height: 220)
                                
                                VStack(spacing: 8) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    Text("Add a photo")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Text("Choose Image")
                                .padding(8)
                                .padding(.horizontal)
                                .background(Color.blue.opacity(0.15))
                                .cornerRadius(8)
                        }
                        .onChange(of: selectedPhoto) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    pickedImageData = data
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    
                    // MARK: Title field
                    TextField("Recipe name", text: $title)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .font(.headline)
                        .padding(.horizontal)
                    
                    
                    // MARK: Category
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Picker("", selection: $category) {
                            ForEach(categories, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    
                    // MARK: Prep time & Calories
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Prep time")
                                .foregroundColor(.secondary)
                            Stepper("\(prepTime) min", value: $prepTime, in: 1...240)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Calories")
                                .foregroundColor(.secondary)
                            Stepper("\(calories)", value: $calories, in: 50...2000)
                        }
                    }
                    .padding(.horizontal)
                    
                    
                    // MARK: Ingredients
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ingredients")
                            .font(.headline)
                        
                        ForEach(ingredients.indices, id: \.self) { i in
                            TextField("Ingredient", text: $ingredients[i])
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        
                        Button {
                            ingredients.append("")
                        } label: {
                            Label("Add ingredient", systemImage: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    
                    // MARK: Steps
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Steps")
                            .font(.headline)
                        
                        ForEach(steps.indices, id: \.self) { i in
                            TextField("Step", text: $steps[i])
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        
                        Button {
                            steps.append("")
                        } label: {
                            Label("Add step", systemImage: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("New Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveRecipe() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    
    // MARK: SAVE
    private func saveRecipe() {
        
        let cleanedIngredients = ingredients.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        let cleanedSteps = steps.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        
        let newRecipe = Recipe(
            id: UUID().uuidString,
            name: title,
            category: category,
            ingredients: cleanedIngredients,
            steps: cleanedSteps,
            prepTime: prepTime,
            calories: calories,
            difficulty: "Easy",
            imageData: pickedImageData   // 🔥 salvata davvero!
        )
        
        recipes.append(newRecipe)
        dismiss()
    }
}
