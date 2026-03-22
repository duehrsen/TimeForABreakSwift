//
//  OptionsView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-31.
//

import SwiftUI

struct OptionsView: View {
    @EnvironmentObject var timerModel: TimerModel
    @EnvironmentObject var optionsModel: OptionsModel
    @EnvironmentObject var allActions: ActionViewModel
    @EnvironmentObject var selectActions: SelectedActionsViewModel

    @State private var showSaveToast = false
    @State private var toastDebounceTask: Task<Void, Never>?
    @State private var showDaySetupFromOptions = false
    @State private var showDaySummaryFromOptions = false

    private func scheduleSettingsToast() {
        toastDebounceTask?.cancel()
        toastDebounceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            showSaveToast = true
        }
    }

    private func persistSettings(updateTimerDurations: Bool) {
        guard optionsModel.options.worktimeMin > 0, optionsModel.options.breaktimeMin > 0 else { return }
        optionsModel.saveToDisk()
        if updateTimerDurations {
            timerModel.updateFromOptions(optionSet: optionsModel.options)
        }
        scheduleSettingsToast()
    }

    private func completeDaySetupFromOptions() {
        let today = Calendar.current.startOfDay(for: Date())
        UserDefaults.standard.set(today, forKey: "lastDaySetupDate")
        showDaySetupFromOptions = false
        showDaySummaryFromOptions = true
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        showDaySetupFromOptions = true
                    } label: {
                        HStack {
                            Text("Plan your day")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)

                    NavigationLink {
                        SuggestedActionsOptionsView()
                    } label: {
                        HStack {
                            Text("Set a default day’s actions")
                            Spacer()
                            Text("\(optionsModel.options.dailySuggestedTitles?.count ?? DataProvider.defaultDailySuggestedActionTitles().count) actions")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    NavigationLink {
                        ActionListView()
                    } label: {
                        HStack {
                            Text("Manage full list")
                            Spacer()
                            Text("\(allActions.actions.count) total")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Planning")
                }

                Section {
                    NavigationLink {
                        WorkTimeSettingsView()
                    } label: {
                        HStack {
                            Text("Work time")
                            Spacer()
                            Text("\(optionsModel.options.worktimeMin) min")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }

                    NavigationLink {
                        BreakTimeSettingsView()
                    } label: {
                        HStack {
                            Text("Break time")
                            Spacer()
                            Text("\(optionsModel.options.breaktimeMin) min")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Durations")
                }

                Section {
                    NavigationLink {
                        TimerCompletionSettingsView()
                    } label: {
                        HStack {
                            Text("Timer completion")
                            Spacer()
                            Text(optionsModel.options.completionFeedback.pickerLabel)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Alerts")
                }

                Section {
                    Toggle("Voice", isOn: $optionsModel.options.speakBreakSuggestions)
                } header: {
                    Text("Next action")
                } footer: {
                    Text("Speak suggested break ideas after each work session.")
                }

                Section {
                    Toggle("Lock screen", isOn: $optionsModel.options.liveActivityEnabled)
                } footer: {
                    Text("Show the timer on the Lock Screen and in the Dynamic Island when a session is running.")
                }
            }
            .listStyle(.insetGrouped)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbars(title: "Options")
            }
            .onChange(of: optionsModel.options.worktimeMin) { _ in
                persistSettings(updateTimerDurations: true)
            }
            .onChange(of: optionsModel.options.breaktimeMin) { _ in
                persistSettings(updateTimerDurations: true)
            }
            .onChange(of: optionsModel.options.completionFeedback) { _ in
                persistSettings(updateTimerDurations: false)
            }
            .onChange(of: optionsModel.options.speakBreakSuggestions) { _ in
                persistSettings(updateTimerDurations: false)
            }
            .onChange(of: optionsModel.options.liveActivityEnabled) { _ in
                persistSettings(updateTimerDurations: false)
            }
            .toast(
                message: "Settings updated",
                isShowing: $showSaveToast,
                config: .init(
                    backgroundColor: .green.opacity(0.85),
                    sysImg: "checkmark.circle.fill"
                )
            )
            .sheet(isPresented: $showDaySetupFromOptions) {
                DaySetupSheetView(onComplete: completeDaySetupFromOptions)
                    .environmentObject(selectActions)
                    .environmentObject(allActions)
                    .environmentObject(optionsModel)
            }
            .sheet(isPresented: $showDaySummaryFromOptions) {
                DayPlanSummaryView()
                    .environmentObject(selectActions)
            }
        }
    }
}

// MARK: - Duration & completion drill-downs

private struct WorkTimeSettingsView: View {
    @EnvironmentObject var optionsModel: OptionsModel

    var body: some View {
        Form {
            Section {
                Stepper("\(optionsModel.options.worktimeMin) minutes", value: $optionsModel.options.worktimeMin, in: 1...60, step: 1)
            } footer: {
                Text("Length of each focus session before a break.")
            }
        }
        .navigationTitle("Work time")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct BreakTimeSettingsView: View {
    @EnvironmentObject var optionsModel: OptionsModel

    var body: some View {
        Form {
            Section {
                Stepper("\(optionsModel.options.breaktimeMin) minutes", value: $optionsModel.options.breaktimeMin, in: 1...40, step: 1)
            } footer: {
                Text("Length of each break before returning to work.")
            }
        }
        .navigationTitle("Break time")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct TimerCompletionSettingsView: View {
    @EnvironmentObject var optionsModel: OptionsModel

    var body: some View {
        Form {
            Section {
                Picker("When timer ends", selection: $optionsModel.options.completionFeedback) {
                    ForEach(TimerCompletionFeedback.allCases, id: \.self) { mode in
                        Text(mode.pickerLabel).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            } footer: {
                Text("Sound, vibration, or nothing when a work or break segment ends in the app.")
            }
        }
        .navigationTitle("Timer completion")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SuggestedActionsOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var allActions: ActionViewModel
    @EnvironmentObject var optionsModel: OptionsModel

    @State private var selectedTitles: Set<String> = []
    @State private var showToast = false
    @State private var toastDebounceTask: Task<Void, Never>?

    private var allTitles: [String] {
        Array(Set(allActions.actions.map { $0.title }))
            .sorted()
    }

    private func loadSelection() {
        if let saved = optionsModel.options.dailySuggestedTitles,
           !saved.isEmpty {
            selectedTitles = Set(saved)
        } else {
            selectedTitles = Set(DataProvider.defaultDailySuggestedActionTitles())
        }
    }

    private func scheduleSuggestionToast() {
        toastDebounceTask?.cancel()
        toastDebounceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            showToast = true
        }
    }

    private func persistSelection() {
        optionsModel.options.dailySuggestedTitles = Array(selectedTitles)
        optionsModel.saveToDisk()
        scheduleSuggestionToast()
    }

    var body: some View {
        List {
            Section("Choose which actions appear in the suggested set") {
                ForEach(allTitles, id: \.self) { title in
                    Button {
                        if selectedTitles.contains(title) {
                            guard selectedTitles.count > 1 else { return }
                            selectedTitles.remove(title)
                        } else {
                            selectedTitles.insert(title)
                        }
                        persistSelection()
                    } label: {
                        HStack {
                            Text(title)
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedTitles.contains(title) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Suggested actions")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .onAppear {
            loadSelection()
        }
        .toast(
            message: "Suggestion set updated",
            isShowing: $showToast,
            config: .init(
                backgroundColor: .green.opacity(0.85),
                sysImg: "checkmark.circle.fill"
            )
        )
    }
}
