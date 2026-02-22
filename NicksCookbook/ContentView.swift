import SwiftUI
import PhotosUI

// MARK: - Content View (Root)

struct ContentView: View {
    @EnvironmentObject var viewModel: RecipeViewModel
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showSettings = false
    @State private var showMoreRecipesSheet = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Header photo area
                        photoSection

                        if viewModel.isAnalyzing {
                            analyzingView
                        } else if !viewModel.identifiedIngredients.isEmpty {
                            ingredientsSection
                        }

                        if !viewModel.recipes.isEmpty {
                            recipesSection
                        }

                        // Error banner
                        if let error = viewModel.errorMessage {
                            ErrorBannerView(message: error)
                                .padding(.horizontal)
                                .padding(.top, 12)
                        }

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Nick's Cookbook")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundColor(.orange)
                    }
                }

                if viewModel.selectedImage != nil && !viewModel.isAnalyzing {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("New Photo") {
                            viewModel.reset()
                        }
                        .foregroundColor(.orange)
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(sourceType: imagePickerSource) { image in
                    Task { await viewModel.analyzeImage(image) }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showMoreRecipesSheet) {
                MoreRecipesSheet()
                    .environmentObject(viewModel)
            }
        }
        .tint(.orange)
    }

    // MARK: - Subviews

    private var photoSection: some View {
        VStack(spacing: 16) {
            if let image = viewModel.selectedImage {
                // Show captured photo
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 260)
                    .clipped()
                    .overlay(alignment: .bottomTrailing) {
                        Button {
                            showPhotoOptions()
                        } label: {
                            Label("Retake", systemImage: "camera.fill")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.black.opacity(0.6))
                                .clipShape(Capsule())
                        }
                        .padding(12)
                    }
            } else {
                // Empty state — prompt to take photo
                emptyStateView
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 40)

            Image(systemName: "refrigerator")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .yellow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolEffect(.pulse)

            VStack(spacing: 8) {
                Text("Nick's Cookbook")
                    .font(.title.bold())
                    .foregroundColor(.primary)

                Text("Snap a photo of your fridge and\nwe'll craft recipes from what's inside.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            VStack(spacing: 12) {
                PhotoButton(
                    title: "Take a Photo",
                    systemImage: "camera.fill",
                    color: .orange
                ) {
                    imagePickerSource = .camera
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        showImagePicker = true
                    }
                }

                PhotoButton(
                    title: "Choose from Library",
                    systemImage: "photo.on.rectangle",
                    color: .blue
                ) {
                    imagePickerSource = .photoLibrary
                    showImagePicker = true
                }
            }
            .padding(.horizontal, 40)

            Spacer(minLength: 40)
        }
        .frame(maxWidth: .infinity, minHeight: 400)
        .background(Color(.systemGroupedBackground))
    }

    private var analyzingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.4)
                .tint(.orange)

            VStack(spacing: 6) {
                Text("Analyzing your fridge...")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("Identifying ingredients and crafting recipes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        .padding(.horizontal)
        .padding(.top, 16)
    }

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Identified Ingredients", systemImage: "cart.fill")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(viewModel.identifiedIngredients.count) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.identifiedIngredients, id: \.self) { ingredient in
                        IngredientTag(name: ingredient)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 8)
        .background(Color(.systemBackground))
        .padding(.top, 8)
    }

    private var recipesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("\(viewModel.recipes.count) Recipes", systemImage: "fork.knife")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 16)

            LazyVStack(spacing: 12) {
                ForEach(Array(viewModel.recipes.enumerated()), id: \.element.id) { index, recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        RecipeCardView(recipe: recipe, index: index)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }
            }

            // More Recipes button
            moreRecipesButton
                .padding(.horizontal)
                .padding(.bottom, 16)
        }
        .padding(.top, 8)
    }

    private var moreRecipesButton: some View {
        Button {
            showMoreRecipesSheet = true
        } label: {
            HStack {
                if viewModel.isLoadingMore {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.9)
                    Text("Getting more recipes...")
                } else {
                    Image(systemName: "plus.circle.fill")
                    Text("Get More Recipes")
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(viewModel.isLoadingMore ? Color.orange.opacity(0.7) : Color.orange)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(viewModel.isLoadingMore)
        .padding(.top, 8)
    }

    // MARK: - Helpers

    private func showPhotoOptions() {
        // Show action sheet for camera vs library
        imagePickerSource = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        showImagePicker = true
    }
}

// MARK: - Supporting Views

struct PhotoButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

struct IngredientTag: View {
    let name: String

    var body: some View {
        Text(name.capitalized)
            .font(.caption.weight(.medium))
            .foregroundColor(.orange)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.12))
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(Color.orange.opacity(0.3), lineWidth: 1)
            )
    }
}

struct ErrorBannerView: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
                .font(.system(size: 16))
            Text(message)
                .font(.caption)
                .foregroundColor(.red)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.red.opacity(0.25), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
