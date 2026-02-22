import SwiftUI

// MARK: - More Recipes Sheet

struct MoreRecipesSheet: View {
    @EnvironmentObject var viewModel: RecipeViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var feedback: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // Illustration
                    headerSection

                    // What you'll get
                    infoSection

                    // Optional feedback
                    feedbackSection

                    // Action buttons
                    actionButtons
                }
                .padding()
            }
            .navigationTitle("More Recipes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.orange)
                }
            }
            .background(Color(.systemGroupedBackground))
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange.opacity(0.2), .yellow.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)

                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            Text("Get More Recipe Ideas")
                .font(.title2.bold())

            Text("Claude will suggest 5 more recipes using the same fridge ingredients — completely different from what you've already seen.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var infoSection: some View {
        HStack(spacing: 16) {
            InfoPill(icon: "arrow.triangle.2.circlepath", text: "No repeated recipes", color: .green)
            InfoPill(icon: "globe", text: "Varied cuisines", color: .blue)
            InfoPill(icon: "plus.circle", text: "Added to your list", color: .orange)
        }
    }

    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Feedback (Optional)", systemImage: "text.bubble")
                    .font(.headline)
                Spacer()
                if !feedback.isEmpty {
                    Button("Clear") {
                        feedback = ""
                        isFocused = false
                    }
                    .font(.caption)
                    .foregroundColor(.orange)
                }
            }

            Text("Tell Claude what you're looking for — a cuisine style, dietary preference, meal type, or anything else.")
                .font(.caption)
                .foregroundColor(.secondary)

            // Quick suggestion chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(feedbackSuggestions, id: \.self) { suggestion in
                        Button {
                            feedback = suggestion
                            isFocused = false
                        } label: {
                            Text(suggestion)
                                .font(.caption.weight(.medium))
                                .foregroundColor(feedback == suggestion ? .white : .orange)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(feedback == suggestion ? Color.orange : Color.orange.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            TextEditor(text: $feedback)
                .focused($isFocused)
                .frame(minHeight: 80, maxHeight: 140)
                .padding(10)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isFocused ? Color.orange : Color(.systemGray4), lineWidth: 1.5)
                )
                .overlay(alignment: .topLeading) {
                    if feedback.isEmpty {
                        Text("e.g., \"Something vegetarian\" or \"Quick weeknight dinner\"")
                            .font(.body)
                            .foregroundColor(.secondary.opacity(0.6))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 18)
                            .allowsHitTesting(false)
                    }
                }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Primary: Get More Recipes
            Button {
                isFocused = false
                dismiss()
                Task {
                    await viewModel.getMoreRecipes(feedback: feedback.isEmpty ? nil : feedback)
                }
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                    Text(feedback.isEmpty ? "Get 5 More Recipes" : "Get Recipes with Feedback")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.orange)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            // Secondary: Skip feedback
            if !feedback.isEmpty {
                Button {
                    isFocused = false
                    feedback = ""
                    dismiss()
                    Task {
                        await viewModel.getMoreRecipes(feedback: nil)
                    }
                } label: {
                    Text("Get Recipes Without Feedback")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
        .padding(.bottom, 8)
    }

    // MARK: - Helpers

    private let feedbackSuggestions = [
        "Vegetarian",
        "Quick & easy",
        "Healthy",
        "Comfort food",
        "Asian cuisine",
        "Italian",
        "High protein",
        "Kid-friendly"
    ]
}

// MARK: - Info Pill

struct InfoPill: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text(text)
                .font(.caption.weight(.medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    MoreRecipesSheet()
        .environmentObject(RecipeViewModel())
}
