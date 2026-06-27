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

    // Ricetta da modificare (nil = modalità "Crea")
    private let editingRecipe: Recipe?

    // Form state
    @State private var name:         String
    @State private var category:     String
    @State private var prepTime:     Int
    @State private var calories:     String
    @State private var difficulty:   String
    @State private var ingredients:  [String]
    @State private var steps:        [String]
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var isFavorite:   Bool

    private let categories   = ["Pasta", "Salad", "Soup", "Meat", "Fish", "Dessert", "Healthy", "Other"]
    private let difficulties = ["Easy", "Medium", "Hard"]

    private var isEditing: Bool { editingRecipe != nil }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        ingredients.contains { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    // MARK: - Init (create)

    init(recipes: Binding<[Recipe]>) {
        self._recipes      = recipes
        self.editingRecipe = nil
        _name         = State(initialValue: "")
        _category     = State(initialValue: "Pasta")
        _prepTime     = State(initialValue: 20)
        _calories     = State(initialValue: "")
        _difficulty   = State(initialValue: "Easy")
        _ingredients  = State(initialValue: [""])
        _steps        = State(initialValue: [""])
        _selectedImage = State(initialValue: nil)
        _isFavorite   = State(initialValue: false)
    }

    // MARK: - Init (edit) — pre-popola tutti i campi dalla ricetta esistente

    init(recipes: Binding<[Recipe]>, editingRecipe: Recipe) {
        self._recipes      = recipes
        self.editingRecipe = editingRecipe

        _name        = State(initialValue: editingRecipe.name)
        _category    = State(initialValue: editingRecipe.category)
        _prepTime    = State(initialValue: editingRecipe.prepTime)
        _calories    = State(initialValue: editingRecipe.calories > 0 ? String(editingRecipe.calories) : "")
        _difficulty  = State(initialValue: editingRecipe.difficulty)
        _ingredients = State(initialValue: editingRecipe.ingredients.isEmpty ? [""] : editingRecipe.ingredients)
        _steps       = State(initialValue: editingRecipe.steps.isEmpty       ? [""] : editingRecipe.steps)
        _isFavorite  = State(initialValue: editingRecipe.isFavorite)

        // Carica l'immagine salvata (se presente)
        if let data = editingRecipe.imageData, let img = UIImage(data: data) {
            _selectedImage = State(initialValue: img)
        } else {
            _selectedImage = State(initialValue: nil)
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            Form {

                // ── Foto ────────────────────────────────────────────
                Section {
                    Button { showImagePicker = true } label: {
                        HStack {
                            Spacer()
                            if let img = selectedImage {
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 140, height: 140)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))

                                    // Indicatore "tap per cambiare"
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .background(Circle().fill(Color.black.opacity(0.4)))
                                        .padding(6)
                                }
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.green)
                                    Text("Add photo")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                }
                                .frame(width: 140, height: 140)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
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

                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(difficulties, id: \.self) { Text($0) }
                    }

                    HStack {
                        Text("Prep time")
                        Spacer()
                        Stepper("\(prepTime) min", value: $prepTime, in: 1...300, step: 5)
                    }

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
                    let filled = ingredients.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count
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
                    Text("\(steps.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count) added")
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
            .navigationTitle(isEditing ? "Edit Recipe" : "New Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Update" : "Save") { saveRecipe() }
                        .bold()
                        .disabled(!canSave)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }

    // MARK: - Save / Update

    private func saveRecipe() {
        let imageData = selectedImage.flatMap { $0.jpegData(compressionQuality: 0.7) }

        let recipe = Recipe(
            id:          editingRecipe?.id ?? UUID().uuidString,
            name:        name.trimmingCharacters(in: .whitespaces),
            imageName:   editingRecipe?.imageName,
            imageData:   imageData,
            calories:    Int(calories) ?? 0,
            prepTime:    prepTime,
            difficulty:  difficulty,
            ingredients: ingredients.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty },
            steps:       steps.filter       { !$0.trimmingCharacters(in: .whitespaces).isEmpty },
            category:    category,
            isFavorite:  isFavorite
        )

        if let existing = editingRecipe,
           let idx = recipes.firstIndex(where: { $0.id == existing.id }) {
            // ← Modalità edit: sostituisce la ricetta esistente
            recipes[idx] = recipe
        } else {
            // ← Modalità create: aggiunge
            recipes.append(recipe)
        }

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
