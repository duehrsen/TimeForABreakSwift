//
//  TimerCompletionView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-12.
//

import SwiftUI
import AVFoundation

struct TimerCompletionView: View {

    @EnvironmentObject var selectActions: SelectedActionsViewModel
    @EnvironmentObject var optionsModel: OptionsModel
    @EnvironmentObject var timerModel: TimerModel

    @State private var player: AVAudioPlayer?
    @State private var speechService = SpeechService()
    @State private var showToast = false
    @State private var toastMessage = ""

    var isFinishedWork: Bool
    let cal = Calendar.current

    private var uncompletedActions: [BreakAction] {
        selectActions.actions.filter {
            (cal.isDateInToday($0.date ?? .distantPast) || $0.pinned) && $0.completed == false
        }
    }

    fileprivate func playSuccessSound() {
        let path = Bundle.main.path(forResource: "hornorganmusichockey.m4a", ofType: nil)!
        let url = URL(fileURLWithPath: path)

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    fileprivate func speakAction() {
        guard isFinishedWork else { return }
        if let action = uncompletedActions.randomElement(), !action.spokenPrompt.isEmpty {
            speechService.speak(action.spokenPrompt)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 30) {
                // Mute/Unmute button
                Button(action: {
                    optionsModel.options.isMuted.toggle()
                    optionsModel.saveToDisk()
                    if optionsModel.options.isMuted {
                        speechService.stop()
                        player?.stop()
                    }
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: optionsModel.options.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .font(.title2)
                        Text(optionsModel.options.isMuted ? "Unmute" : "Mute")
                            .font(.title3)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(optionsModel.options.isMuted ? Color.red.opacity(0.2) : Color.blue.opacity(0.2))
                    .clipShape(Capsule())
                }
                .padding(.top, 16)

                Spacer()
                Text(isFinishedWork ? "Time for a break!" : "Hope you are recharged!")
                    .font(.title2)
                    .lineLimit(4)
                    .minimumScaleFactor(0.5)
                    .foregroundColor(Color.blue)
                    .frame(width: geometry.size.width - 20, alignment: .center)
                Image(systemName: isFinishedWork ? "hands.sparkles.fill" : "bolt.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color.yellow)
                    .frame(width: geometry.size.width - 20, alignment: .center)
                    .onAppear {
                        timerModel.switchMode()
                    }
                if isFinishedWork {
                    List {
                        Section("Some actions left to do") {
                        }
                        ForEach(uncompletedActions, id: \.id) { item in
                            SimpleActionRowView(action: item)
                        }
                    }
                    .listStyle(.plain)
                    .frame(width: geometry.size.width - 20, alignment: .center)

                    VoiceInputView(
                        actions: selectActions.actions,
                        speechService: speechService
                    ) { result in
                        handleVoiceMatch(result)
                    }
                    .padding(.horizontal)
                } else {
                    SelectedActionsSheetView(isFromCompletedSheet: true)
                        .frame(width: geometry.size.width - 20, alignment: .center)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            if !optionsModel.options.isMuted {
                playSuccessSound()
                speakAction()
            }
        }
        .onDisappear {
            speechService.stop()
        }
        .edgesIgnoringSafeArea(.all)
        .toast(message: toastMessage, sysImg: "checkmark.circle.fill", isShowing: $showToast, duration: Toast.longDuration)
    }

    private func handleVoiceMatch(_ result: PhraseMatching.MatchResult) {
        let action = result.action

        // Record the completion
        selectActions.addCompletion(actionId: action.id, quantity: result.quantity, source: .voice)

        // Mark the action as completed in selected actions
        selectActions.update(id: action.id, newtitle: action.title, duration: action.duration, completed: true)

        // Build feedback message
        var feedback = "Got it! \(action.title)"
        if let quantity = result.quantity, let unit = action.unit {
            feedback = "Got it! \(quantity) \(unit) logged."
        }

        // Speak feedback if not muted
        if !optionsModel.options.isMuted {
            speechService.speak(feedback)
        }

        // Show toast
        toastMessage = feedback
        showToast = true
    }
}
