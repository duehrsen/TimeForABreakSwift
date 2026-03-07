//
//  VoiceRecognitionService.swift
//  TimeForABreakSwiftUI
//

import AVFoundation
import Combine
import Foundation
import Speech

/// Wraps SFSpeechRecognizer + AVAudioEngine to provide live speech-to-text.
@MainActor
class VoiceRecognitionService: ObservableObject {

    enum AuthorizationState {
        case notDetermined
        case authorized
        case denied
        case restricted
    }

    enum ListeningState: Equatable {
        case idle
        case listening
        case processing
        case error(String)
    }

    @Published private(set) var authorizationState: AuthorizationState = .notDetermined
    @Published private(set) var listeningState: ListeningState = .idle
    @Published private(set) var transcribedText: String = ""

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var autoStopTask: Task<Void, Never>?

    /// Maximum listening duration in seconds before auto-stopping.
    private let maxListeningDuration: TimeInterval = 10

    // MARK: - Authorization

    func checkAuthorization() {
        let status = SFSpeechRecognizer.authorizationStatus()
        authorizationState = mapAuthStatus(status)
    }

    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            Task { @MainActor in
                self?.authorizationState = self?.mapAuthStatus(status) ?? .denied
            }
        }
    }

    private func mapAuthStatus(_ status: SFSpeechRecognizerAuthorizationStatus) -> AuthorizationState {
        switch status {
        case .authorized: return .authorized
        case .denied: return .denied
        case .restricted: return .restricted
        case .notDetermined: return .notDetermined
        @unknown default: return .denied
        }
    }

    // MARK: - Listening

    func startListening() {
        guard listeningState == .idle || listeningState != .listening else { return }
        guard speechRecognizer?.isAvailable == true else {
            listeningState = .error("Speech recognition is not available")
            return
        }

        // Reset state
        transcribedText = ""
        stopRecognition()

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            recognitionRequest = request

            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                request.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()

            recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
                Task { @MainActor in
                    guard let self else { return }

                    if let result {
                        self.transcribedText = result.bestTranscription.formattedString
                    }

                    if let error {
                        // Ignore cancellation errors from intentional stops
                        let nsError = error as NSError
                        if nsError.domain != "kAFAssistantErrorDomain" || nsError.code != 216 {
                            self.listeningState = .error(error.localizedDescription)
                        }
                        self.stopEngine()
                    }
                }
            }

            listeningState = .listening

            // Auto-stop after timeout
            autoStopTask?.cancel()
            autoStopTask = Task {
                try? await Task.sleep(for: .seconds(maxListeningDuration))
                if !Task.isCancelled && self.listeningState == .listening {
                    self.stopListening()
                }
            }

        } catch {
            listeningState = .error("Failed to start audio: \(error.localizedDescription)")
        }
    }

    func stopListening() {
        autoStopTask?.cancel()
        autoStopTask = nil

        guard listeningState == .listening else { return }
        listeningState = .processing
        stopRecognition()
        stopEngine()
        listeningState = .idle
    }

    func reset() {
        autoStopTask?.cancel()
        autoStopTask = nil
        stopRecognition()
        stopEngine()
        transcribedText = ""
        listeningState = .idle
    }

    // MARK: - Private helpers

    private func stopRecognition() {
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
    }

    private func stopEngine() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        // Restore audio session for TTS playback
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
}
