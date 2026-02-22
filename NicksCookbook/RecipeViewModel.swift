import Foundation
import UIKit
import Combine

// MARK: - Recipe View Model

@MainActor
final class RecipeViewModel: ObservableObject {

    // MARK: - Published State

    @Published var recipes: [Recipe] = []
    @Published var identifiedIngredients: [String] = []
    @Published var selectedImage: UIImage?
    @Published var isAnalyzing = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var hasAnalyzed = false

    // MARK: - API Key (persisted in UserDefaults)

    @Published var apiKey: String {
        didSet {
            UserDefaults.standard.set(apiKey, forKey: "NCB_anthropic_api_key")
            rebuildService()
        }
    }

    // MARK: - Private

    private var claudeService: ClaudeService?

    // MARK: - Init

    init() {
        self.apiKey = UserDefaults.standard.string(forKey: "NCB_anthropic_api_key") ?? ""
        rebuildService()
    }

    // MARK: - Public Actions

    /// Analyzes the given image for ingredients and generates 5 initial recipes.
    func analyzeImage(_ image: UIImage) async {
        guard let service = claudeService else {
            errorMessage = "Please add your Anthropic API key in Settings (tap the gear icon)."
            return
        }

        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            errorMessage = "Could not process the selected image."
            return
        }

        isAnalyzing = true
        errorMessage = nil
        recipes = []
        identifiedIngredients = []
        selectedImage = image
        hasAnalyzed = false

        do {
            let (ingredients, newRecipes) = try await service.analyzeImageAndGetRecipes(imageData: imageData)
            identifiedIngredients = ingredients
            recipes = newRecipes
            hasAnalyzed = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isAnalyzing = false
    }

    /// Fetches 5 more recipes, optionally using the provided feedback.
    func getMoreRecipes(feedback: String?) async {
        guard let service = claudeService else { return }
        guard hasAnalyzed else { return }

        isLoadingMore = true
        errorMessage = nil

        do {
            let moreRecipes = try await service.getMoreRecipes(feedback: feedback)
            recipes.append(contentsOf: moreRecipes)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingMore = false
    }

    /// Resets all state so the user can start over with a new photo.
    func reset() {
        recipes = []
        identifiedIngredients = []
        selectedImage = nil
        isAnalyzing = false
        isLoadingMore = false
        errorMessage = nil
        hasAnalyzed = false
    }

    // MARK: - Private

    private func rebuildService() {
        guard !apiKey.trimmingCharacters(in: .whitespaces).isEmpty else {
            claudeService = nil
            return
        }
        claudeService = ClaudeService(apiKey: apiKey.trimmingCharacters(in: .whitespaces))
    }
}
