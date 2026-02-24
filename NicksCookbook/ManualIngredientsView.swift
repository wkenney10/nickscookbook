import SwiftUI
import Speech
import AVFoundation

// MARK: - Voice Input Manager

final class VoiceInputManager: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var transcript = ""
    @Published var permissionError: String?

    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))

    func start() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            guard status == .authorized else {
                DispatchQueue.main.async { self.permissionError = "Speech recognition permission denied." }
                return
            }
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                guard granted else {
                    DispatchQueue.main.async { self.permissionError = "Microphone permission denied." }
                    return
                }
                DispatchQueue.main.async { self.beginRecording() }
            }
        }
    }

    func stop() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        audioEngine = nil
        recognitionRequest = nil
        recognitionTask = nil
        DispatchQueue.main.async { self.isRecording = false }
    }

    private func beginRecording() {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            permissionError = "Speech recognition is not available."
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)

            let engine = AVAudioEngine()
            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true

            recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
                guard let self = self else { return }
                if let result = result {
                    DispatchQueue.main.async { self.transcript = result.bestTranscription.formattedString }
                }
                if error != nil || (result?.isFinal ?? false) {
                    self.stop()
                }
            }

            let inputNode = engine.inputNode
            let format = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                request.append(buffer)
            }

            engine.prepare()
            try engine.start()

            audioEngine = engine
            recognitionRequest = request
            isRecording = true
            transcript = ""
        } catch {
            permissionError = "Could not start recording: \(error.localizedDescription)"
        }
    }
}

// MARK: - Manual Ingredients View

struct ManualIngredientsView: View {
    @EnvironmentObject var viewModel: RecipeViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var voiceManager = VoiceInputManager()

    @State private var inputText = ""
    @State private var ingredients: [String] = []
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                inputSection
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                Divider()

                if ingredients.isEmpty {
                    emptyListPlaceholder
                } else {
                    ingredientList
                }

                Spacer()

                actionSection
                    .padding(.horizontal)
                    .padding(.bottom, 12)
            }
            .navigationTitle("Your Ingredients")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.orange)
                }
            }
            .background(Color(.systemGroupedBackground))
            .alert("Permission Required", isPresented: .constant(voiceManager.permissionError != nil)) {
                Button("OK") { voiceManager.permissionError = nil }
            } message: {
                Text(voiceManager.permissionError ?? "")
            }
            .onChange(of: voiceManager.isRecording) { _, recording in
                if !recording && !voiceManager.transcript.isEmpty {
                    inputText = voiceManager.transcript
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onDisappear { voiceManager.stop() }
    }

    // MARK: - Subviews

    private var inputSection: some View {
        VStack(spacing: 10) {
            // Text field row
            HStack(spacing: 10) {
                TextField("e.g., eggs, butter, garlic", text: $inputText)
                    .focused($isTextFieldFocused)
                    .submitLabel(.done)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onSubmit { addFromTextField() }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isTextFieldFocused ? Color.orange : Color(.systemGray4), lineWidth: 1.5)
                    )

                Button(action: addFromTextField) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .orange)
                }
                .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            // Voice button row
            HStack(spacing: 10) {
                Button(action: toggleVoice) {
                    HStack(spacing: 6) {
                        Image(systemName: voiceManager.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.system(size: 18))
                        Text(voiceManager.isRecording ? "Stop" : "Voice Input")
                            .font(.subheadline.weight(.medium))
                    }
                    .foregroundColor(voiceManager.isRecording ? .white : .orange)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(voiceManager.isRecording ? Color.red : Color.orange.opacity(0.12))
                    .clipShape(Capsule())
                }

                if voiceManager.isRecording {
                    HStack(spacing: 4) {
                        RecordingPulse()
                        Text(voiceManager.transcript.isEmpty ? "Listening…" : voiceManager.transcript)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    Text("Separate multiple items with commas")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var emptyListPlaceholder: some View {
        VStack(spacing: 14) {
            Image(systemName: "cart.badge.plus")
                .font(.system(size: 52))
                .foregroundStyle(
                    LinearGradient(colors: [.orange, .yellow],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .padding(.top, 40)

            Text("No ingredients yet")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Type or speak your ingredients above.\nSeparate multiple items with commas.")
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
    }

    private var ingredientList: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Your Ingredients")
                    .font(.headline)
                Spacer()
                Text("\(ingredients.count) item\(ingredients.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 14)
            .padding(.bottom, 8)

            List {
                ForEach(ingredients, id: \.self) { ingredient in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 7, height: 7)
                        Text(ingredient.capitalized)
                            .font(.body)
                        Spacer()
                    }
                }
                .onDelete { indexSet in
                    ingredients.remove(atOffsets: indexSet)
                }
            }
            .listStyle(.plain)
            .frame(maxHeight: 300)
        }
        .background(Color(.systemBackground))
    }

    private var actionSection: some View {
        Button {
            isTextFieldFocused = false
            voiceManager.stop()
            let finalList = ingredients
            dismiss()
            Task { await viewModel.analyzeTextIngredients(finalList) }
        } label: {
            HStack {
                Image(systemName: "wand.and.stars")
                Text("Get Recipes")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(ingredients.isEmpty ? Color.orange.opacity(0.4) : Color.orange)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(ingredients.isEmpty)
    }

    // MARK: - Helpers

    private func addFromTextField() {
        let trimmed = inputText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        // Support comma-separated bulk entry
        let items = trimmed
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        for item in items {
            if !ingredients.contains(where: { $0.lowercased() == item.lowercased() }) {
                ingredients.append(item)
            }
        }
        inputText = ""
    }

    private func toggleVoice() {
        if voiceManager.isRecording {
            voiceManager.stop()
        } else {
            inputText = ""
            voiceManager.start()
        }
    }
}

// MARK: - Recording Pulse Indicator

struct RecordingPulse: View {
    @State private var animate = false

    var body: some View {
        Circle()
            .fill(Color.red)
            .frame(width: 8, height: 8)
            .scaleEffect(animate ? 1.3 : 1.0)
            .opacity(animate ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: animate)
            .onAppear { animate = true }
    }
}
