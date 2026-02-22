import SwiftUI

// MARK: - Recipe Detail View

struct RecipeDetailView: View {
    let recipe: Recipe
    @State private var servings: Int
    @State private var completedSteps: Set<Int> = []
    @Environment(\.dismiss) private var dismiss

    init(recipe: Recipe) {
        self.recipe = recipe
        self._servings = State(initialValue: recipe.servings)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero header
                heroHeader

                // Time & servings row
                statsRow
                    .padding(.horizontal)
                    .padding(.vertical, 16)

                Divider().padding(.horizontal)

                // Ingredients section
                ingredientsSection
                    .padding()

                Divider().padding(.horizontal)

                // Instructions section
                instructionsSection
                    .padding()
            }
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareLink(
                    item: shareText,
                    subject: Text(recipe.name),
                    message: Text("From Nick's Cookbook")
                ) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [.orange, .yellow],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 180)

            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.name)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 2)

                Text(recipe.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(3)
            }
            .padding(20)
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 0) {
            StatBox(icon: "clock.fill", value: recipe.prepTime, label: "Prep Time", color: .blue)
            Divider().frame(height: 40)
            StatBox(icon: "flame.fill", value: recipe.cookTime, label: "Cook Time", color: .orange)
            Divider().frame(height: 40)
            StatBox(icon: "person.2.fill", value: "\(servings)", label: "Servings", color: .green)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4)
    }

    // MARK: - Ingredients

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Ingredients", systemImage: "cart.fill")
                    .font(.title3.bold())
                Spacer()
                // Servings adjuster
                HStack(spacing: 12) {
                    Button {
                        if servings > 1 { servings -= 1 }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title3)
                            .foregroundColor(servings > 1 ? .orange : .gray)
                    }
                    .disabled(servings <= 1)

                    Text("\(servings)")
                        .font(.headline.monospacedDigit())
                        .frame(minWidth: 24)

                    Button {
                        servings += 1
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.orange)
                    }
                }
            }

            VStack(spacing: 0) {
                ForEach(Array(recipe.ingredients.enumerated()), id: \.offset) { index, ingredient in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 7, height: 7)
                            .padding(.top, 6)

                        Text(scaledIngredient(ingredient))
                            .font(.body)
                            .foregroundColor(.primary)

                        Spacer()
                    }
                    .padding(.vertical, 8)

                    if index < recipe.ingredients.count - 1 {
                        Divider()
                    }
                }
            }
            .padding(12)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.04), radius: 4)
        }
    }

    // MARK: - Instructions

    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Instructions", systemImage: "list.number")
                .font(.title3.bold())

            VStack(spacing: 12) {
                ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                    StepView(
                        stepNumber: index + 1,
                        text: step,
                        isCompleted: completedSteps.contains(index)
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            if completedSteps.contains(index) {
                                completedSteps.remove(index)
                            } else {
                                completedSteps.insert(index)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func scaledIngredient(_ ingredient: String) -> String {
        guard servings != recipe.servings, recipe.servings > 0 else { return ingredient }
        let ratio = Double(servings) / Double(recipe.servings)

        // Try to scale the first number found in the ingredient string
        var result = ingredient
        let pattern = #"(\d+(?:\.\d+)?)"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: ingredient, range: NSRange(ingredient.startIndex..., in: ingredient)),
           let range = Range(match.range(at: 1), in: ingredient),
           let originalValue = Double(ingredient[range]) {
            let scaledValue = originalValue * ratio
            let formatted = scaledValue.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(scaledValue))
                : String(format: "%.1f", scaledValue)
            result = ingredient.replacingCharacters(in: range, with: formatted)
        }
        return result
    }

    private var shareText: String {
        var text = "🍽 \(recipe.name)\n\n"
        text += recipe.description + "\n\n"
        text += "⏱ Prep: \(recipe.prepTime) | Cook: \(recipe.cookTime) | Serves \(recipe.servings)\n\n"
        text += "Ingredients:\n" + recipe.ingredients.map { "• \($0)" }.joined(separator: "\n")
        text += "\n\nInstructions:\n" + recipe.instructions.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
        text += "\n\n— From Nick's Cookbook"
        return text
    }
}

// MARK: - Supporting Views

struct StatBox: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }
}

struct StepView: View {
    let stepNumber: Int
    let text: String
    let isCompleted: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 14) {
                // Step number badge
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.green : Color.orange)
                        .frame(width: 32, height: 32)

                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Text("\(stepNumber)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .animation(.spring(response: 0.3), value: isCompleted)

                Text(text)
                    .font(.body)
                    .foregroundColor(isCompleted ? .secondary : .primary)
                    .strikethrough(isCompleted, color: .secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
            .background(
                isCompleted
                    ? Color.green.opacity(0.08)
                    : Color(.systemBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isCompleted ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
            .animation(.spring(response: 0.3), value: isCompleted)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: Recipe(
            name: "Chicken Caesar Salad",
            description: "A timeless classic with crispy romaine lettuce, grilled chicken, parmesan shavings, and a creamy Caesar dressing that never disappoints.",
            ingredients: ["2 chicken breasts", "1 head romaine lettuce", "1/4 cup parmesan", "2 tbsp olive oil", "1 lemon"],
            instructions: [
                "Preheat the oven to 400°F and season chicken with salt and pepper.",
                "Brush chicken with olive oil and roast for 20 minutes until cooked through.",
                "Let chicken rest 5 minutes, then slice thinly.",
                "Wash and dry romaine leaves, then chop into bite-sized pieces.",
                "Toss lettuce with Caesar dressing, top with chicken and parmesan. Serve immediately."
            ],
            prepTime: "15 min",
            cookTime: "20 min",
            servings: 4
        ))
    }
}
