//
//  TimerVoiceLogSheetView.swift
//  TimeForABreakSwiftUI
//

import SwiftUI

struct TimerVoiceLogSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var selectActions: SelectedActionsViewModel
    @EnvironmentObject var optionsModel: OptionsModel
    @EnvironmentObject var allActions: ActionViewModel

    @State private var speechService = SpeechService()
    @State private var toastMessage: String = ""
    @State private var showToast: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Log actions by voice")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("Say what you just did, for example \"did pushups\", \"drank water twice\", or \"took a short walk\".")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VoiceInputView(
                    actions: allActions.actions,
                    speechService: speechService
                ) { result in
                    handleVoiceMatch(result)
                }
                .padding()

                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .toast(message: toastMessage, sysImg: "checkmark.circle.fill", isShowing: $showToast, duration: Toast.shortDuration)
        }
    }

    private func handleVoiceMatch(_ result: PhraseMatching.MatchResult) {
        let template = result.action
        let action = selectActions.ensureTodayInstance(from: template)

        selectActions.addCompletion(actionId: action.id, quantity: result.quantity, source: .voice)
        selectActions.update(id: action.id, newtitle: action.title, duration: action.duration, completed: true)

        var feedback = "Got it! \(action.title)"
        if let quantity = result.quantity, let unit = action.unit {
            feedback = "Got it! \(quantity) \(unit) logged."
        }

        if !optionsModel.options.isMuted {
            speechService.speak(feedback)
        }

        toastMessage = feedback
        showToast = true
    }
}

