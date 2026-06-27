//
//  RecipeFormView.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 16/11/25.
//

import SwiftUI

struct RecipeFormView: View {

    @Binding var recipes: [Recipe]
    @Environment(\.dismiss) private var dismiss

    // Form state
    @State private var name        = ""
    @State private var category    = "Pasta"
    @State private var prepTime    = 20
    @State private var calories    = ""
    @State private var difficulty  = "Easy"        // ← ora usato davvero
    @State private var ingredients: [String] = [""]
    @State private var steps:       [String] = [""]
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var isFavorite  = false

    private let categories  = ["Pasta", "Salad", "Soup", "Meat", "Fish", "Dessert", "Healthy", "Other"]
    private let difficulties = ["Easy", "Medium", "Hard"]

    // Save abilitato solo se nome e almeno 1 ingrediente non vuoto
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        ingredients.contains { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    var body: some View {
        NavigationView {
            Form {

                // ── Foto ────────────────────────────────────────────
                Section {
                    Button {
                        showImagePicker = true
                    } label: {
                        HStack {
                            Spacer()
                            if let img = selectedImage {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.green)
                                    Text("Add photo")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                }
                                .frame(width: 120, height: 120)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.clear)
                }

                // ── Info base ────────────────────────────────────────
                Section("Recipe info") {
                    TextField("Name", text: $name)

                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }

                    // FIX: Picker difficulty funzionante
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(difficulties, id: \.self) { Text($0) }
                    }

                    HStack {
                        Text("Prep time")
                        Spacer()
                        Stepper("\(prepTime) min", value: $prepTime, in: 1...300, step: 5)
                    }

                    // FIX: keyboardType .numberPad
                    HStack {
                        Text("Calories (kcal)")
                        Spacer()
                        TextField("0", text: $calories)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }

                    Toggle("Favourite", isOn: $isFavorite)
                }

                // ── Ingredienti ──────────────────────────────────────
                Section(header: HStack {
                    Text("Ingredients")
                    Spacer()
                    // Contatore
                    let filled = ingredients.filter { !$0.isEmpty }.count
                    Text("\(filled) added")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }) {
                    ForEach(ingredients.indices, id: \.self) { i in
                        HStack {
                            TextField("Ingredient \(i + 1)", text: $ingredients[i])
                            if ingredients.count > 1 {
                                Button {
                                    ingredients.remove(at: i)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    Button {
                        ingredients.append("")
                    } label: {
                        Label("Add ingredient", systemImage: "plus.circle")
                            .foregroundColor(.green)
                    }
                }

                // ── Steps ────────────────────────────────────────────
                Section(header: HStack {
                    Text("Steps")
                    Spacer()
                    Text("\(steps.filter { !$0.isEmpty }.count) added")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }) {
                    ForEach(steps.indices, id: \.self) { i in
                        HStack(alignment: .top) {
                            Text("\(i + 1).")
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                            TextField("Step \(i + 1)", text: $steps[i], axis: .vertical)
                                .lineLimit(1...4)
                            if steps.count > 1 {
                                Button {
                                    steps.remove(at: i)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.plain)
                                .padding(.top, 4)
                            }
                        }
                    }
                    Button {
                        steps.append("")
                    } label: {
                        Label("Add step", systemImage: "plus.circle")
                            .foregroundColor(.green)
                    }
                }

                // Validation hint
                if !canSave {
                    Section {
                        Label("Add a name and at least one ingredient to save.", systemImage: "info.circle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("New Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveRecipe() }
                        .bold()
                        .disabled(!canSave)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }

    // MARK: - Save

    private func saveRecipe() {
        let imageData = selectedImage.flatMap { $0.jpegData(compressionQuality: 0.7) }

        let newRecipe = Recipe(
            id:          UUID().uuidString,
            name:        name.trimmingCharacters(in: .whitespaces),
            imageName:   nil,
            imageData:   imageData,
            calories:    Int(calories) ?? 0,
            prepTime:    prepTime,
            difficulty:  difficulty,              // ← FIX: non più "Easy" hardcoded
            ingredients: ingredients.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty },
            steps:       steps.filter       { !$0.trimmingCharacters(in: .whitespaces).isEmpty },
            category:    category,
            isFavorite:  isFavorite
        )

        recipes.append(newRecipe)
        RecipeStorage.save(recipes)
        dismiss()
    }
}

// MARK: - ImagePicker

struct ImagePicker: UIViewControllerRepresentable {

    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.image = (info[.editedImage] ?? info[.originalImage]) as? UIImage
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
