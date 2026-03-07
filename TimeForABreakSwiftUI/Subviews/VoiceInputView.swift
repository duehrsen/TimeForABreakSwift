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
    @State private var showNoMatch = false
    @State private var showConfirmation = false
    @State private var lastUnmatchedText = ""

    var body: some View {
        VStack(spacing: 16) {
            micButton
            statusText
            if showNoMatch {
                noMatchView
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
            if let result = PhraseMatching.processTranscript(newValue, actions: actions) {
                matchResult = result
                showNoMatch = false
                showConfirmation = true
                voiceService.stopListening()
                onMatch(result)
            }
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
                if !showNoMatch && !showConfirmation {
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
                Text(message)
                    .font(.caption)
                    .foregroundColor(.red)
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

    private func confirmationView(_ result: PhraseMatching.MatchResult) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text(result.action.title)
                    .font(.subheadline)
                    .bold()
                if let quantity = result.quantity, let unit = result.action.unit {
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

    private func handleMicTap() {
        switch voiceService.authorizationState {
        case .notDetermined:
            voiceService.requestAuthorization()
        case .authorized:
            if voiceService.listeningState == .listening {
                voiceService.stopListening()
            } else {
                // Reset state for new attempt
                matchResult = nil
                showNoMatch = false
                showConfirmation = false
                speechService.stop() // Stop TTS before recording
                voiceService.startListening()
            }
        case .denied, .restricted:
            break
        }
    }
}
