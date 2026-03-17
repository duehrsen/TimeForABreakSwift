//
//  OptionsView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-31.
//

import SwiftUI

struct OptionsView: View {
    @EnvironmentObject var timerModel: TimerModel
    @EnvironmentObject var optionsModel : OptionsModel
    @EnvironmentObject var allActions: ActionViewModel
    @State private var showSaveToast = false
    var body: some View {
        NavigationStack {
            List {
                Section("Timer") {
                    OptionsInputSubView()
                }

                Section("Manage break actions") {
                    NavigationLink {
                        ActionListView()
                    } label: {
                        HStack {
                            Text("Full list")
                            Spacer()
                            Text("\(allActions.actions.count) total")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    NavigationLink {
                        SuggestedActionsOptionsView()
                    } label: {
                        HStack {
                            Text("Suggestion set")
                            Spacer()
                            Text("\(optionsModel.options.dailySuggestedTitles?.count ?? DataProvider.defaultDailySuggestedActionTitles().count) actions")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section {
                    Button(action: {
                        if optionsModel.options.worktimeMin > 0 && optionsModel.options.breaktimeMin > 0 {
                            let newOptions = OptionSet(
                                breaktimeMin: optionsModel.options.breaktimeMin,
                                worktimeMin: optionsModel.options.worktimeMin,
                                doesPlaySounds: optionsModel.options.doesPlaySounds,
                                isMuted: optionsModel.options.isMuted,
                                dailySuggestedTitles: optionsModel.options.dailySuggestedTitles,
                                dailyActionGoal: optionsModel.options.dailyActionGoal
                            )
                            Task {
                                try? await optionsModel.save(options: newOptions)
                            }
                            timerModel.updateFromOptions(optionSet: newOptions)
                            showSaveToast = true
                        }
                    }) {
                        HStack(spacing: 15){
                            Spacer()
                            Text("Save")
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding()
                        .background(Color.green)
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbars(title: "Options")
            }
            .toast(
                message: "Options saved",
                isShowing: $showSaveToast,
                config: .init(
                    backgroundColor: .green.opacity(0.85),
                    sysImg: "checkmark.circle.fill"
                )
            )
        }
    }
}

struct SuggestedActionsOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var allActions: ActionViewModel
    @EnvironmentObject var optionsModel: OptionsModel

    @State private var selectedTitles: Set<String> = []

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

    private func saveSelection() {
        optionsModel.options.dailySuggestedTitles = Array(selectedTitles)
        optionsModel.saveToDisk()
        dismiss()
    }

    var body: some View {
        List {
            Section("Choose which actions appear in the suggested set") {
                ForEach(allTitles, id: \.self) { title in
                    Button {
                        if selectedTitles.contains(title) {
                            selectedTitles.remove(title)
                        } else {
                            selectedTitles.insert(title)
                        }
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
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveSelection()
                }
                .disabled(selectedTitles.isEmpty)
            }
        }
        .onAppear {
            loadSelection()
        }
    }
}

