import Foundation
import UIKit

// MARK: - Claude Service

actor ClaudeService {
    private let baseURL = "https://api.anthropic.com/v1/messages"
    private let apiKey: String

    // Raw conversation history stored as dictionaries for flexible message building
    private var conversationHistory: [[String: Any]] = []

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    // MARK: - Public Interface

    /// Analyzes a fridge image and returns identified ingredients + 5 recipes.
    func analyzeImageAndGetRecipes(imageData: Data) async throws -> (ingredients: [String], recipes: [Recipe]) {
        conversationHistory = []

        let base64Image = imageData.base64EncodedString()

        let imageContent: [String: Any] = [
            "type": "image",
            "source": [
                "type": "base64",
                "media_type": "image/jpeg",
                "data": base64Image
            ] as [String: Any]
        ]

        let textContent: [String: Any] = [
            "type": "text",
            "text": initialRecipePrompt()
        ]

        let userMessage: [String: Any] = [
            "role": "user",
            "content": [imageContent, textContent]
        ]

        conversationHistory.append(userMessage)

        let responseText = try await callClaude(systemPrompt: systemPrompt())
        conversationHistory.append(["role": "assistant", "content": responseText])

        return try parseRecipeResponse(responseText)
    }

    /// Analyzes a plain-text ingredient list and returns 5 recipes (no image required).
    func analyzeTextIngredients(ingredients: [String]) async throws -> (ingredients: [String], recipes: [Recipe]) {
        conversationHistory = []

        let ingredientList = ingredients.joined(separator: ", ")
        let textContent: [String: Any] = [
            "type": "text",
            "text": textIngredientPrompt(ingredientList)
        ]

        let userMessage: [String: Any] = [
            "role": "user",
            "content": [textContent]
        ]

        conversationHistory.append(userMessage)

        let responseText = try await callClaude(systemPrompt: systemPrompt())
        conversationHistory.append(["role": "assistant", "content": responseText])

        return try parseRecipeResponse(responseText)
    }

    /// Requests 5 more recipes, optionally considering user feedback.
    /// `currentIngredients` ensures any edits the user made to the ingredient list are honoured.
    func getMoreRecipes(feedback: String?, currentIngredients: [String]) async throws -> [Recipe] {
        let feedbackClause: String
        if let feedback = feedback, !feedback.isEmpty {
            feedbackClause = " taking this feedback into account: \"\(feedback)\""
        } else {
            feedbackClause = ""
        }

        let ingredientList = currentIngredients.isEmpty
            ? "the same ingredients identified earlier"
            : currentIngredients.joined(separator: ", ")

        let prompt = """
        Please suggest 5 more different recipes\(feedbackClause). Use these ingredients: \(ingredientList). Do NOT repeat any recipes already provided. Aim for variety — different cuisines, cooking methods, and meal types.

        Respond ONLY with valid JSON in this exact format:
        {
            "identified_ingredients": [],
            "recipes": [
                {
                    "name": "Recipe Name",
                    "description": "Brief, appetizing description",
                    "ingredients": ["amount ingredient", ...],
                    "instructions": ["Step 1: ...", "Step 2: ...", ...],
                    "prep_time": "X minutes",
                    "cook_time": "X minutes",
                    "servings": 4
                }
            ]
        }
        """

        let userMessage: [String: Any] = [
            "role": "user",
            "content": prompt
        ]
        conversationHistory.append(userMessage)

        let responseText = try await callClaude(systemPrompt: nil)
        conversationHistory.append(["role": "assistant", "content": responseText])

        let (_, recipes) = try parseRecipeResponse(responseText)
        return recipes
    }

    // MARK: - Private Helpers

    private func systemPrompt() -> String {
        """
        You are Nick's Cookbook — a friendly, expert culinary assistant. Your specialty is identifying ingredients in fridge photos and crafting creative, delicious recipes from whatever is available.

        Guidelines:
        - Be practical: use visible ingredients as the foundation, supplemented by common pantry staples (oil, salt, pepper, basic spices, pasta, rice, etc.)
        - Be creative: suggest varied cuisines and cooking styles
        - Be encouraging: write appetizing descriptions that make recipes sound irresistible
        - Always respond with valid JSON only — no extra text before or after the JSON object
        """
    }

    private func textIngredientPrompt(_ ingredientList: String) -> String {
        """
        I have these ingredients available: \(ingredientList)

        Please suggest exactly 5 delicious, practical recipes using these ingredients (supplemented by common pantry staples like oil, salt, pepper, pasta, rice, etc.).

        Respond ONLY with a valid JSON object in this exact format — no other text:
        {
            "identified_ingredients": [\(ingredientList.split(separator: ",").map { "\"\($0.trimmingCharacters(in: .whitespaces))\"" }.joined(separator: ", "))],
            "recipes": [
                {
                    "name": "Recipe Name",
                    "description": "Brief, appetizing description (2-3 sentences)",
                    "ingredients": ["2 cups ingredient1", "1 tbsp ingredient2", ...],
                    "instructions": ["Step 1: ...", "Step 2: ...", ...],
                    "prep_time": "15 minutes",
                    "cook_time": "25 minutes",
                    "servings": 4
                }
            ]
        }

        Make sure:
        - Each recipe uses primarily the listed ingredients
        - Instructions are clear and numbered
        - Times are realistic
        - Variety across the 5 recipes (different meals, cuisines, complexity levels)
        """
    }

    private func initialRecipePrompt() -> String {
        """
        Please analyze this fridge photo carefully and:
        1. Identify all visible ingredients (be specific — note quantities where visible)
        2. Suggest exactly 5 delicious, practical recipes using these ingredients

        Respond ONLY with a valid JSON object in this exact format — no other text:
        {
            "identified_ingredients": ["ingredient1", "ingredient2", ...],
            "recipes": [
                {
                    "name": "Recipe Name",
                    "description": "Brief, appetizing description (2-3 sentences)",
                    "ingredients": ["2 cups ingredient1", "1 tbsp ingredient2", ...],
                    "instructions": ["Step 1: ...", "Step 2: ...", ...],
                    "prep_time": "15 minutes",
                    "cook_time": "25 minutes",
                    "servings": 4
                }
            ]
        }

        Make sure:
        - Each recipe uses primarily the visible fridge ingredients
        - Instructions are clear and numbered
        - Times are realistic
        - Variety across the 5 recipes (different meals, cuisines, complexity levels)
        """
    }

    private func callClaude(systemPrompt: String?) async throws -> String {
        guard !apiKey.isEmpty else {
            throw ClaudeError.missingAPIKey
        }

        var requestBody: [String: Any] = [
            "model": "claude-opus-4-6",
            "max_tokens": 4096,
            "thinking": ["type": "adaptive"] as [String: Any],
            "messages": conversationHistory
        ]

        if let system = systemPrompt {
            requestBody["system"] = system
        }

        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = jsonData
        request.timeoutInterval = 180

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClaudeError.invalidResponse
        }

        if httpResponse.statusCode != 200 {
            let errorBody = String(data: data, encoding: .utf8) ?? "No error body"
            throw ClaudeError.apiError(statusCode: httpResponse.statusCode, message: errorBody)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]] else {
            throw ClaudeError.invalidResponse
        }

        // Filter for text blocks (skip thinking blocks)
        guard let textBlock = content.first(where: { $0["type"] as? String == "text" }),
              let text = textBlock["text"] as? String else {
            throw ClaudeError.invalidResponse
        }

        return text
    }

    private func parseRecipeResponse(_ response: String) throws -> (ingredients: [String], recipes: [Recipe]) {
        // Extract the JSON object from the response text
        let jsonString = extractJSON(from: response)

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw ClaudeError.parseError("Could not convert response to data")
        }

        do {
            let analysisResponse = try JSONDecoder().decode(FridgeAnalysisResponse.self, from: jsonData)
            return (analysisResponse.identifiedIngredients, analysisResponse.recipes)
        } catch {
            throw ClaudeError.parseError("JSON decode failed: \(error.localizedDescription)\n\nResponse was: \(jsonString.prefix(500))")
        }
    }

    /// Extracts the outermost JSON object from a string that may contain extra text.
    private func extractJSON(from text: String) -> String {
        var depth = 0
        var startIndex: String.Index?
        var endIndex: String.Index?

        for (idx, char) in text.enumerated() {
            let index = text.index(text.startIndex, offsetBy: idx)
            if char == "{" {
                if depth == 0 {
                    startIndex = index
                }
                depth += 1
            } else if char == "}" {
                depth -= 1
                if depth == 0, let start = startIndex {
                    endIndex = text.index(after: index)
                    return String(text[start..<endIndex!])
                }
            }
        }

        return text
    }
}

// MARK: - Errors

enum ClaudeError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case apiError(statusCode: Int, message: String)
    case parseError(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "No API key configured. Please add your Anthropic API key in Settings."
        case .invalidResponse:
            return "Received an invalid response from the Claude API."
        case .apiError(let code, let message):
            return "API Error \(code): \(message)"
        case .parseError(let detail):
            return "Failed to parse recipe data: \(detail)"
        }
    }
}
