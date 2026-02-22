import SwiftUI

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject var viewModel: RecipeViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var draftKey: String = ""
    @State private var showKey = false
    @State private var saved = false
    @FocusState private var isKeyFieldFocused: Bool

    var body: some View {
        NavigationStack {
            List {
                // API Key Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Anthropic API Key", systemImage: "key.fill")
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text("Nick's Cookbook uses Claude (claude-opus-4-6) to analyze your fridge and generate recipes. You'll need an Anthropic API key.")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        // Key input field
                        HStack {
                            Group {
                                if showKey {
                                    TextField("sk-ant-...", text: $draftKey)
                                        .focused($isKeyFieldFocused)
                                } else {
                                    SecureField("sk-ant-...", text: $draftKey)
                                        .focused($isKeyFieldFocused)
                                }
                            }
                            .font(.system(.body, design: .monospaced))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)

                            Button {
                                showKey.toggle()
                            } label: {
                                Image(systemName: showKey ? "eye.slash" : "eye")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(12)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isKeyFieldFocused ? Color.orange : Color(.systemGray4), lineWidth: 1.5)
                        )

                        // Current status
                        if !viewModel.apiKey.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text("API key configured")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                Spacer()
                                // Masked key display
                                Text(maskedKey(viewModel.apiKey))
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                                Text("No API key configured")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }

                        // Save button
                        HStack(spacing: 12) {
                            Button {
                                viewModel.apiKey = draftKey
                                isKeyFieldFocused = false
                                withAnimation {
                                    saved = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation { saved = false }
                                }
                            } label: {
                                HStack {
                                    if saved {
                                        Image(systemName: "checkmark")
                                        Text("Saved!")
                                    } else {
                                        Image(systemName: "square.and.arrow.down")
                                        Text("Save Key")
                                    }
                                }
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(saved ? Color.green : Color.orange)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .animation(.spring(response: 0.3), value: saved)
                            .disabled(draftKey.trimmingCharacters(in: .whitespaces).isEmpty)

                            if !viewModel.apiKey.isEmpty {
                                Button {
                                    viewModel.apiKey = ""
                                    draftKey = ""
                                } label: {
                                    Text("Clear")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.red)
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 20)
                                        .background(Color.red.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("API Configuration")
                } footer: {
                    Text("Your API key is stored locally on this device and never shared. Keys begin with \"sk-ant-\".")
                }

                // How to get a key
                Section("Get an API Key") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Visit console.anthropic.com")
                        Text("2. Create or sign in to your account")
                        Text("3. Go to API Keys → Create Key")
                        Text("4. Copy and paste your key above")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 4)
                }

                // About
                Section("About") {
                    HStack {
                        Text("App Name")
                        Spacer()
                        Text("Nick's Cookbook")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("AI Model")
                        Spacer()
                        Text("claude-opus-4-6")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Powered by")
                        Spacer()
                        Text("Anthropic Claude")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.orange)
                }
            }
        }
        .onAppear {
            draftKey = viewModel.apiKey
        }
    }

    private func maskedKey(_ key: String) -> String {
        guard key.count > 8 else { return String(repeating: "•", count: key.count) }
        let prefix = String(key.prefix(7))
        let suffix = String(key.suffix(4))
        return "\(prefix)...\(suffix)"
    }
}

#Preview {
    SettingsView()
        .environmentObject(RecipeViewModel())
}
