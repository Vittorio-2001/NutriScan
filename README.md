🍏 NutriScan — Smart Food Scanner & Recipe Assistant

Your personal nutrition companion, inspired by Yuka & Crouton.

📱 Overview

NutriScan is an iOS application built entirely with SwiftUI, designed to scan food products, analyze their nutritional values, and recommend relevant recipes automatically.

The app combines the essential features of apps like Yuka (barcode scanning, product analysis) and Crouton (recipe browsing and creation) into a single, elegant experience.

⸻

✨ Features

🔍 Scan Products (Barcode Scanner)
	•	Instant barcode detection
	•	Product data fetched from OpenFoodFacts API
	•	Auto-generated nutrition sheet (calories, fats, sugars, proteins)
	•	Health score (1–100)
	•	Suggested recipes based on the scanned item

⸻

📚 Recipe Library
	•	View all recipes in a clean Crouton-like layout
	•	Add new recipes with:
	•	photo picker (from library)
	•	ingredients
	•	preparation steps
	•	prep time
	•	calories
	•	category
	•	Recipes are stored locally and persist across app launches

⸻

📜 Scan History
	•	Every scanned product is saved automatically
	•	Persistent storage
	•	Tap any product to view its nutritional details
	•	Suggested recipes appear based on the product
	•	Option to clear history with one tap

⸻

📁 Local Persistence

Using UserDefaults with JSON encoding:
	•	Saves recipes
	•	Saves scan history
	•	Loads everything instantly on launch

⸻

🛠️ Tech Stack
	•	SwiftUI
	•	AVFoundation (live barcode scanning)
	•	AsyncImage for remote images
	•	PhotosPicker (iOS 16+)
	•	UserDefaults + Codable for persistence
	•	OpenFoodFacts API for product lookups
⸻

🚀 How It Works

1. Scan a Product

The camera detects a barcode →
The app calls OpenFoodFacts →
Creates a ScannedProduct →
Saves it to history →
Shows a detailed bottom sheet.

2. Explore Recipes

Users can:
	•	scroll through recipes
	•	create new ones
	•	view them with images
	•	search + filter (if implemented)

3. Suggested Recipes

Matches product keywords with:
	•	recipe name
	•	ingredients

Returns the best 3 suggestions.

