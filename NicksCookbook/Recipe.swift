import Foundation

// MARK: - Recipe Model

struct Recipe: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let ingredients: [String]
    let instructions: [String]
    let prepTime: String
    let cookTime: String
    let servings: Int

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        ingredients: [String],
        instructions: [String],
        prepTime: String,
        cookTime: String,
        servings: Int
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.ingredients = ingredients
        self.instructions = instructions
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.servings = servings
    }

    enum CodingKeys: String, CodingKey {
        case name, description, ingredients, instructions, servings
        case prepTime = "prep_time"
        case cookTime = "cook_time"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.ingredients = try container.decode([String].self, forKey: .ingredients)
        self.instructions = try container.decode([String].self, forKey: .instructions)
        self.prepTime = (try? container.decodeIfPresent(String.self, forKey: .prepTime)) ?? "15 min"
        self.cookTime = (try? container.decodeIfPresent(String.self, forKey: .cookTime)) ?? "30 min"
        self.servings = (try? container.decodeIfPresent(Int.self, forKey: .servings)) ?? 4
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(ingredients, forKey: .ingredients)
        try container.encode(instructions, forKey: .instructions)
        try container.encode(prepTime, forKey: .prepTime)
        try container.encode(cookTime, forKey: .cookTime)
        try container.encode(servings, forKey: .servings)
    }

    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - API Response Models

struct FridgeAnalysisResponse: Decodable {
    let identifiedIngredients: [String]
    let recipes: [Recipe]

    enum CodingKeys: String, CodingKey {
        case identifiedIngredients = "identified_ingredients"
        case recipes
    }
}

// MARK: - Claude API Models

struct ClaudeMessage: Encodable {
    let role: String
    let content: ClaudeContent

    enum ClaudeContent {
        case text(String)
        case multipart([ClaudeContentBlock])
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(role, forKey: .role)
        switch content {
        case .text(let text):
            try container.encode(text, forKey: .content)
        case .multipart(let blocks):
            try container.encode(blocks, forKey: .content)
        }
    }

    enum CodingKeys: String, CodingKey {
        case role, content
    }
}

struct ClaudeContentBlock: Encodable {
    let type: String
    var text: String?
    var source: ImageSource?

    struct ImageSource: Encodable {
        let type: String
        let mediaType: String
        let data: String

        enum CodingKeys: String, CodingKey {
            case type
            case mediaType = "media_type"
            case data
        }
    }
}

struct ClaudeRequest: Encodable {
    let model: String
    let maxTokens: Int
    let thinking: ThinkingConfig
    let system: String?
    let messages: [ClaudeRawMessage]

    struct ThinkingConfig: Encodable {
        let type: String
    }

    enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case thinking, system, messages
    }
}

struct ClaudeRawMessage: Encodable {
    let role: String
    let content: AnyEncodable
}

// Helper to encode any Encodable value
struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void

    init<T: Encodable>(_ value: T) {
        encodeFunc = { encoder in
            try value.encode(to: encoder)
        }
    }

    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}

struct ClaudeResponse: Decodable {
    let content: [ContentBlock]

    struct ContentBlock: Decodable {
        let type: String
        let text: String?
    }
}
