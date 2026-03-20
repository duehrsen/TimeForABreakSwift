//
//  TimerCompletionView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-12.
//

import SwiftUI
import AVFoundation
import UIKit

struct TimerCompletionView: View {

    @EnvironmentObject var selectActions: SelectedActionsViewModel
    @EnvironmentObject var optionsModel: OptionsModel
    @EnvironmentObject var timerModel: TimerModel
    @EnvironmentObject var allActions: ActionViewModel

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

    private var suggestedTitles: Set<String> {
        if let titles = optionsModel.options.dailySuggestedTitles,
           !titles.isEmpty {
            return Set(titles)
        } else {
            return Set(DataProvider.defaultDailySuggestedActionTitles())
        }
    }

    private var suggestedUncompletedActions: [BreakAction] {
        uncompletedActions.filter { suggestedTitles.contains($0.title) }
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

    fileprivate func playCompletionHaptic() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(isFinishedWork ? .success : .warning)
    }

    fileprivate func speakAction() {
        guard isFinishedWork else { return }
        let source = suggestedUncompletedActions.isEmpty ? uncompletedActions : suggestedUncompletedActions
        if let action = source.randomElement(), !action.spokenPrompt.isEmpty {
            speechService.speak(action.spokenPrompt)
        }
    }

    fileprivate func applyCompletionFeedback() {
        switch optionsModel.options.completionFeedback {
        case .sound:
            playSuccessSound()
        case .haptic:
            playCompletionHaptic()
        case .none:
            break
        }
        if optionsModel.options.speakBreakSuggestions {
            speakAction()
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 30) {
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
                        actions: allActions.actions,
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
            applyCompletionFeedback()
        }
        .onDisappear {
            speechService.stop()
        }
        .edgesIgnoringSafeArea(.all)
        .toast(message: toastMessage, sysImg: "checkmark.circle.fill", isShowing: $showToast, duration: Toast.longDuration)
    }

    private func handleVoiceMatch(_ result: PhraseMatching.MatchResult) {
        let template = result.action
        let action = selectActions.ensureTodayInstance(from: template)

        // Record the completion
        selectActions.addCompletion(actionId: action.id, quantity: result.quantity, source: .voice)

        // Mark the action as completed in selected actions
        selectActions.update(id: action.id, newtitle: action.title, duration: action.duration, completed: true)

        // Build feedback message
        var feedback = "Got it! \(action.title)"
        if let quantity = result.quantity, let unit = action.displayUnit(forQuantity: quantity) {
            feedback = "Got it! \(quantity) \(unit) logged."
        }

        if optionsModel.options.speakBreakSuggestions {
            speechService.speak(feedback)
        }

        // Show toast
        toastMessage = feedback
        showToast = true
    }
}
