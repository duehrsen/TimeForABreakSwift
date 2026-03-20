//
//  VoiceInputView.swift
//  TimeForABreakSwiftUI
//

import SwiftUI

/// Self-contained voice input component with microphone button,
/// live transcription, and real-time phrase matching.
struct VoiceInputView: View {
    let actions: [BreakAction]
    let speechService: SpeechService
    let onMatch: (PhraseMatching.MatchResult) -> Void

    @StateObject private var voiceService = VoiceRecognitionService()

    @State private var matchResult: PhraseMatching.MatchResult?
    @State private var candidateResults: [PhraseMatching.MatchResult] = []
    @State private var showSuggestions = false
    @State private var showNoMatch = false
    @State private var showConfirmation = false
    @State private var lastUnmatchedText = ""
    @State private var showVoicePrePrompt = false

    var body: some View {
        VStack(spacing: 16) {
            micButton
            statusText
            if showNoMatch {
                noMatchView
            }
            if showSuggestions && !candidateResults.isEmpty {
                suggestionsView
            }
            if showConfirmation, let result = matchResult {
                confirmationView(result)
            }
        }
        .onAppear {
            voiceService.checkAuthorization()
        }
        .onChange(of: voiceService.transcribedText) { newValue in
            guard !newValue.isEmpty else { return }
            handleTranscriptChange(newValue)
        }
        .onChange(of: voiceService.listeningState) { newValue in
            // When transitioning to idle without a match
            if newValue == .idle,
               matchResult == nil,
               !voiceService.transcribedText.isEmpty {
                lastUnmatchedText = voiceService.transcribedText
                showNoMatch = true
            }
        }
        .alert("Use your voice to log breaks", isPresented: $showVoicePrePrompt) {
            Button("Not now", role: .cancel) { }
            Button("Continue") {
                UserDefaults.standard.set(true, forKey: "hasShownVoicePrePrompt")
                voiceService.requestAuthorization()
            }
        } message: {
            Text("We'll use the microphone and speech recognition only to understand what break you did. You can always use the list instead.")
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var micButton: some View {
        let isListening = voiceService.listeningState == .listening
        let isDisabled = voiceService.authorizationState == .denied
            || voiceService.authorizationState == .restricted

        Button {
            handleMicTap()
        } label: {
            Image(systemName: isListening ? "mic.fill" : "mic")
                .font(.system(size: 40))
                .foregroundColor(isDisabled ? .gray : isListening ? .red : .blue)
                .frame(width: 80, height: 80)
                .background(
                    Circle()
                        .fill(isListening ? Color.red.opacity(0.15) : Color.blue.opacity(0.1))
                )
                .scaleEffect(isListening ? 1.1 : 1.0)
                .animation(
                    isListening
                        ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                        : .default,
                    value: isListening
                )
        }
        .disabled(isDisabled)
        .accessibilityLabel(isListening ? "Stop listening" : "Start voice input")
    }

    @ViewBuilder
    private var statusText: some View {
        switch voiceService.authorizationState {
        case .denied:
            Text("Speech recognition denied. Enable it in Settings.")
                .font(.caption)
                .foregroundColor(.red)
        case .restricted:
            Text("Speech recognition is restricted on this device.")
                .font(.caption)
                .foregroundColor(.red)
        case .notDetermined:
            Text("Tap the microphone to start")
                .font(.caption)
                .foregroundColor(.secondary)
        case .authorized:
            switch voiceService.listeningState {
            case .idle:
                if !showNoMatch && !showConfirmation && !showSuggestions {
                    Text("Tap the microphone to log an action by voice")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            case .listening:
                if voiceService.transcribedText.isEmpty {
                    Text("Listening...")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                } else {
                    Text(voiceService.transcribedText)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .italic()
                }
            case .processing:
                Text("Processing...")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            case .error(let message):
                // If we already have a successful match/confirmation, prefer that
                // over showing an error message from the recognizer.
                if showConfirmation {
                    EmptyView()
                } else {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
    }

    private var noMatchView: some View {
        VStack(spacing: 8) {
            Text("I heard: \"\(lastUnmatchedText)\"")
                .font(.subheadline)
                .foregroundColor(.orange)
            Text("Try again?")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.orange.opacity(0.1))
        )
    }

    private var suggestionsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Did you mean:")
                .font(.caption)
                .foregroundColor(.secondary)

            ForEach(candidateResults, id: \.action.id) { result in
                Button {
                    handleSuggestionTap(result)
                } label: {
                    HStack {
                        Text(result.action.title)
                            .font(.subheadline)
                        Spacer()
                        if let quantity = result.quantity, let unit = result.action.displayUnit(forQuantity: quantity) {
                            Text("\(quantity) \(unit)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.05))
                    )
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue.opacity(0.2))
        )
    }

    private func confirmationView(_ result: PhraseMatching.MatchResult) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text(result.action.title)
                    .font(.subheadline)
                    .bold()
                if let quantity = result.quantity, let unit = result.action.displayUnit(forQuantity: quantity) {
                    Text("\(quantity) \(unit) logged")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Logged")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.green.opacity(0.1))
        )
    }

    // MARK: - Actions

    private func handleTranscriptChange(_ text: String) {
        let matches = PhraseMatching.findMatchingActions(spokenText: text, actions: actions)

        guard !matches.isEmpty else {
            // Let the idle transition handle the "no match" UI
            return
        }

        voiceService.stopListening()
        showNoMatch = false

        if matches.count == 1 {
            // Single clear match – behave like before
            let result = PhraseMatching.matchResult(for: matches[0], in: text)
            matchResult = result
            showConfirmation = true
            showSuggestions = false
            onMatch(result)
        } else {
            // Multiple possible matches – offer suggestions
            candidateResults = matches.map { PhraseMatching.matchResult(for: $0, in: text) }
            matchResult = nil
            showConfirmation = false
            showSuggestions = true
        }
    }

    private func handleSuggestionTap(_ result: PhraseMatching.MatchResult) {
        matchResult = result
        showSuggestions = false
        showConfirmation = true
        onMatch(result)
    }

    private func handleMicTap() {
        switch voiceService.authorizationState {
        case .notDetermined:
            let hasShown = UserDefaults.standard.bool(forKey: "hasShownVoicePrePrompt")
            if hasShown {
                voiceService.requestAuthorization()
            } else {
                showVoicePrePrompt = true
            }
        case .authorized:
            if voiceService.listeningState == .listening {
                voiceService.stopListening()
            } else {
                // Reset state for new attempt
                matchResult = nil
                candidateResults = []
                showNoMatch = false
                showConfirmation = false
                showSuggestions = false
                speechService.stop() // Stop TTS before recording
                voiceService.startListening()
            }
        case .denied, .restricted:
            break
        }
    }
}
