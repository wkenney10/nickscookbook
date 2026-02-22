# Nick's Cookbook 🍳

An iOS app that photographs your fridge and uses Claude AI to identify ingredients and suggest personalized recipes.

## Features

- **Photo capture** — Take a photo with your camera or select from your library
- **AI ingredient detection** — Claude (claude-opus-4-6) identifies everything visible in your fridge
- **5 instant recipes** — Get 5 tailored recipes generated from your ingredients
- **More recipes on demand** — Request additional recipe batches any time
- **Feedback-driven suggestions** — Guide new recipes with preferences ("vegetarian", "quick & easy", "Italian", etc.)
- **Interactive recipe detail** — Step-by-step instructions with tap-to-complete steps and servings scaler
- **Share recipes** — Share any recipe as formatted text

## Requirements

- Xcode 15+ / iOS 17+
- An [Anthropic API key](https://console.anthropic.com)

## Setup

1. Clone the repository
2. Open `NicksCookbook.xcodeproj` in Xcode
3. Build and run on your device or simulator
4. Tap the **gear icon** (⚙) to open Settings and enter your Anthropic API key

## Architecture

```
NicksCookbook/
├── NicksCookbookApp.swift      # App entry point
├── ContentView.swift           # Root view — photo capture, ingredients, recipe list
├── Recipe.swift                # Data models (Recipe, API request/response types)
├── ClaudeService.swift         # Claude API integration (image analysis, recipe generation)
├── RecipeViewModel.swift       # State management, bridges service ↔ UI
├── RecipeCardView.swift        # Recipe list card
├── RecipeDetailView.swift      # Full recipe with interactive steps & servings scaler
├── MoreRecipesSheet.swift      # Sheet for requesting more recipes with optional feedback
├── ImagePickerView.swift       # Camera / photo library picker
└── SettingsView.swift          # API key configuration
```

## How It Works

1. **Image Analysis** — The fridge photo is encoded as base64 JPEG and sent to the Claude API with a vision prompt requesting structured JSON output listing ingredients and recipes.

2. **Recipe Generation** — Claude returns a JSON object with:
   - `identified_ingredients` — list of all visible ingredients
   - `recipes` — array of recipe objects (name, description, ingredients, instructions, prep/cook times, servings)

3. **More Recipes** — Conversation history is preserved in `ClaudeService` so that follow-up "more recipes" requests have context about the original fridge contents and previously suggested recipes, ensuring no repeats.

4. **Feedback** — Optional free-text feedback (or quick-select chips like "Vegetarian" or "Quick & easy") is appended to the follow-up prompt, letting Claude tailor the next batch of recipes.

## API Key Security

The API key is stored in `UserDefaults` for demo purposes. For a production app, store it in the iOS **Keychain** instead.

## Claude Model

Uses `claude-opus-4-6` with `thinking: {type: "adaptive"}` for high-quality ingredient identification and creative recipe generation.
