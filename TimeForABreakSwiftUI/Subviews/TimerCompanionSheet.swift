//
//  TimerCompanionSheet.swift
//  TimeForABreakSwiftUI
//

import SwiftUI

/// Shared metrics for the persistent companion sheet and main timer inset.
enum CompanionSheetLayout {
    /// Collapsed detent as a fraction of screen height; keep in sync with `PresentationDetent.companionCollapsed`.
    static let collapsedHeightFraction: CGFloat = 0.2
}

extension PresentationDetent {
    /// Short strip: log shortcuts only (intrinsic-height content; avoid `ScrollView` as root or it snaps to ~`.medium`).
    static let companionCollapsed = PresentationDetent.fraction(CompanionSheetLayout.collapsedHeightFraction)
}

struct TimerCompanionSheet: View {
    @Binding var detent: PresentationDetent
    @Binding var showVoiceLog: Bool
    @Binding var showListLog: Bool
    @Binding var showManualDayPlan: Bool

    @EnvironmentObject private var timerModel: TimerModel
    @EnvironmentObject private var optionsModel: OptionsModel
    @EnvironmentObject private var selectActions: SelectedActionsViewModel
    @EnvironmentObject private var allActions: ActionViewModel

    private var suggestionCount: Int {
        optionsModel.options.dailySuggestedTitles?.count ?? DataProvider.defaultDailySuggestedActionTitles().count
    }

    private var completionFeedbackSummary: String {
        optionsModel.options.completionFeedback.pickerLabel
    }

    private var bindingLiveActivityEnabled: Binding<Bool> {
        Binding(
            get: { optionsModel.options.liveActivityEnabled },
            set: { newValue in
                var o = optionsModel.options
                o.liveActivityEnabled = newValue
                optionsModel.options = o
                optionsModel.saveToDisk()
            }
        )
    }

    private var bindingLiveActivityShowsNextAction: Binding<Bool> {
        Binding(
            get: { optionsModel.options.liveActivityShowsNextAction },
            set: { newValue in
                var o = optionsModel.options
                o.liveActivityShowsNextAction = newValue
                optionsModel.options = o
                optionsModel.saveToDisk()
            }
        )
    }

    private var bindingSpeakBreakSuggestions: Binding<Bool> {
        Binding(
            get: { optionsModel.options.speakBreakSuggestions },
            set: { newValue in
                var o = optionsModel.options
                o.speakBreakSuggestions = newValue
                optionsModel.options = o
                optionsModel.saveToDisk()
            }
        )
    }

    var body: some View {
        Group {
            if detent == .large {
                NavigationStack {
                    List {
                        Section("Planning") {
                            Button {
                                showManualDayPlan = true
                            } label: {
                                Label("Plan your day", systemImage: "checklist")
                            }
                            .buttonStyle(.borderless)

                            NavigationLink {
                                SuggestedActionsOptionsView()
                            } label: {
                                HStack {
                                    Label("Set a default day’s actions", systemImage: "star.circle")
                                    Spacer()
                                    Text("\(suggestionCount) actions")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }

                            NavigationLink {
                                ActionListView()
                            } label: {
                                HStack {
                                    Label("Manage full action list", systemImage: "list.bullet")
                                    Spacer()
                                    Text("\(allActions.actions.count) total")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        Section("Summary") {
                            NavigationLink {
                                TodaySummaryView()
                            } label: {
                                Label("Today", systemImage: "sun.max")
                            }
                            NavigationLink {
                                YesterdaySummaryView()
                            } label: {
                                Label("Yesterday", systemImage: "calendar")
                            }
                        }

                        Section("Timer") {
                            NavigationLink {
                                WorkTimeSettingsView()
                            } label: {
                                HStack {
                                    Label("Work time", systemImage: "briefcase")
                                    Spacer()
                                    Text("\(optionsModel.options.worktimeMin) min")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            NavigationLink {
                                BreakTimeSettingsView()
                            } label: {
                                HStack {
                                    Label("Break time", systemImage: "cup.and.saucer")
                                    Spacer()
                                    Text("\(optionsModel.options.breaktimeMin) min")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        Section("Alerts & lock screen") {
                            NavigationLink {
                                TimerCompletionSettingsView()
                            } label: {
                                HStack {
                                    Label("Timer completion", systemImage: "bell")
                                    Spacer()
                                    Text(completionFeedbackSummary)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        Section {
                            Toggle("Voice", isOn: bindingSpeakBreakSuggestions)
                            Toggle("Text", isOn: bindingLiveActivityShowsNextAction)
                        } header: {
                            Text("Next action")
                        } footer: {
                            Text("Voice: speak break suggestions when a work segment ends. Text: show the next action on the Lock Screen and Dynamic Island.")
                        }

                        Section {
                            Toggle("Lock screen", isOn: bindingLiveActivityEnabled)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .navigationTitle("Menu")
                    .navigationBarTitleDisplayMode(.inline)
                }
            } else {
                // No ScrollView here: a scroll view expands vertically and the sheet clamps to ~`.medium` instead of the short detent.
                HStack(spacing: 12) {
                    Button {
                        showVoiceLog = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "mic.fill")
                            Text("Log by voice")
                        }
                    }
                    .buttonStyle(PrimaryPillButtonStyle(background: .blue))

                    Button {
                        showListLog = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checklist")
                            Text("Log from list")
                        }
                    }
                    .buttonStyle(PrimaryPillButtonStyle(background: .green))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .presentationDetents([.companionCollapsed, .large], selection: $detent)
        .presentationBackgroundInteraction(.enabled(upThrough: .companionCollapsed))
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(true)
        .sheet(isPresented: $showManualDayPlan) {
            DaySetupSheetView(onComplete: { showManualDayPlan = false })
                .environmentObject(selectActions)
                .environmentObject(allActions)
                .environmentObject(optionsModel)
        }
        .sheet(isPresented: $showVoiceLog) {
            TimerVoiceLogSheetView()
                .environmentObject(selectActions)
                .environmentObject(optionsModel)
                .environmentObject(allActions)
        }
        .sheet(isPresented: $showListLog) {
            SelectedActionsSheetView()
                .environmentObject(selectActions)
                .environmentObject(optionsModel)
        }
    }
}

// MARK: - Timer settings drill-downs (Save / Cancel)

struct WorkTimeSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var timerModel: TimerModel
    @EnvironmentObject private var optionsModel: OptionsModel

    @State private var draftWork: Int = 20

    var body: some View {
        Form {
            Section {
                Stepper("\(draftWork) minutes", value: $draftWork, in: 1...60, step: 1)
            } footer: {
                Text("Length of each work interval.")
            }
        }
        .navigationTitle("Work time")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    guard draftWork > 0 else { return }
                    var o = optionsModel.options
                    o.worktimeMin = draftWork
                    optionsModel.options = o
                    optionsModel.saveToDisk()
                    timerModel.updateFromOptions(optionSet: optionsModel.options)
                    dismiss()
                }
            }
        }
        .onAppear {
            draftWork = optionsModel.options.worktimeMin
        }
    }
}

struct BreakTimeSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var timerModel: TimerModel
    @EnvironmentObject private var optionsModel: OptionsModel

    @State private var draftBreak: Int = 5

    var body: some View {
        Form {
            Section {
                Stepper("\(draftBreak) minutes", value: $draftBreak, in: 1...40, step: 1)
            } footer: {
                Text("Length of each break interval.")
            }
        }
        .navigationTitle("Break time")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    guard draftBreak > 0 else { return }
                    var o = optionsModel.options
                    o.breaktimeMin = draftBreak
                    optionsModel.options = o
                    optionsModel.saveToDisk()
                    timerModel.updateFromOptions(optionSet: optionsModel.options)
                    dismiss()
                }
            }
        }
        .onAppear {
            draftBreak = optionsModel.options.breaktimeMin
        }
    }
}

struct TimerCompletionSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var optionsModel: OptionsModel

    @State private var draftFeedback: TimerCompletionFeedback = .haptic

    var body: some View {
        Form {
            Section {
                Picker("When timer ends", selection: $draftFeedback) {
                    ForEach(TimerCompletionFeedback.allCases, id: \.self) { mode in
                        Text(mode.pickerLabel).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            } footer: {
                Text("Sound, vibration, or no alert when a work or break segment ends in the app.")
            }
        }
        .navigationTitle("Timer completion")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    var o = optionsModel.options
                    o.completionFeedback = draftFeedback
                    optionsModel.options = o
                    optionsModel.saveToDisk()
                    dismiss()
                }
            }
        }
        .onAppear {
            draftFeedback = optionsModel.options.completionFeedback
        }
    }
}
