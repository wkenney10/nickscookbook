import SwiftUI

// MARK: - Recipe Card (used in the list)

struct RecipeCardView: View {
    let recipe: Recipe
    let index: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Color header bar
            headerBar

            // Content
            VStack(alignment: .leading, spacing: 10) {
                // Recipe name
                Text(recipe.name)
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                // Description
                Text(recipe.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // Meta row
                HStack(spacing: 16) {
                    MetaItem(systemImage: "clock", text: recipe.prepTime, label: "Prep")
                    MetaItem(systemImage: "flame", text: recipe.cookTime, label: "Cook")
                    MetaItem(systemImage: "person.2", text: "\(recipe.servings)", label: "Serves")
                    Spacer()

                    // Chevron indicator
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.orange.opacity(0.7))
                }
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
    }

    // MARK: - Header bar with color based on recipe index

    private var headerBar: some View {
        HStack {
            // Recipe number badge
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 32, height: 32)

                Text("\(index + 1)")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.white)
            }
            Spacer()

            // Ingredient count
            Label("\(recipe.ingredients.count) ingredients", systemImage: "list.bullet")
                .font(.caption.weight(.medium))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            LinearGradient(
                colors: gradientColors,
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }

    private var gradientColors: [Color] {
        let palettes: [[Color]] = [
            [.orange, .yellow],
            [.pink, .orange],
            [.purple, .pink],
            [.blue, .teal],
            [.green, .teal],
            [.red, .orange],
            [.indigo, .blue],
            [.cyan, .green],
            [.orange, .red],
            [.yellow, .green]
        ]
        return palettes[index % palettes.count]
    }
}

// MARK: - Meta Item

struct MetaItem: View {
    let systemImage: String
    let text: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.orange)
                Text(text)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
            }
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ScrollView {
        LazyVStack(spacing: 12) {
            ForEach(0..<3) { i in
                RecipeCardView(
                    recipe: Recipe(
                        name: "Chicken Caesar Salad",
                        description: "A classic salad with crispy romaine, creamy dressing, and parmesan.",
                        ingredients: ["2 chicken breasts", "1 head romaine", "Parmesan"],
                        instructions: ["Cook chicken", "Toss salad"],
                        prepTime: "15 min",
                        cookTime: "20 min",
                        servings: 4
                    ),
                    index: i
                )
            }
        }
        .padding()
    }
}
