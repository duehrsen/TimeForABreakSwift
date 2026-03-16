//
//  DaySetupSheetView.swift
//  TimeForABreakSwiftUI
//

import SwiftUI

struct DaySetupSheetView: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject var selectActions: SelectedActionsViewModel
    @EnvironmentObject var allActions: ActionViewModel
    @EnvironmentObject var optionsModel: OptionsModel

    let onComplete: () -> Void

    private var hasYesterdayActions: Bool {
        !selectActions.yesterdayActions().isEmpty
    }

    private var suggestedTitles: [String] {
        if let saved = optionsModel.options.dailySuggestedTitles,
           !saved.isEmpty {
            return saved
        }
        return DataProvider.defaultDailySuggestedActionTitles()
    }

    private func buildSuggestedTemplates() -> [BreakAction] {
        var templates: [BreakAction] = []
        for title in suggestedTitles {
            if let action = allActions.actions.first(where: { $0.title == title }) {
                templates.append(action)
            }
        }
        return templates
    }

    private func useSameAsYesterday() {
        let templates = selectActions.yesterdayActions()
        guard !templates.isEmpty else { return }
        selectActions.setTodaysActions(from: templates)
        onComplete()
        dismiss()
    }

    private func useSuggestedSet() {
        let templates = buildSuggestedTemplates()
        guard !templates.isEmpty else { return }
        selectActions.setTodaysActions(from: templates)
        onComplete()
        dismiss()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Your break actions for today")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 16)

                VStack(spacing: 16) {
                    Button(action: useSameAsYesterday) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Same as yesterday")
                                    .font(.headline)
                                Text("Reuse the actions you completed yesterday.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    .disabled(!hasYesterdayActions)
                    .opacity(hasYesterdayActions ? 1.0 : 0.4)

                    Button(action: useSuggestedSet) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Use suggested set")
                                    .font(.headline)
                                Text("Start with your configured daily suggestions.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "sparkles")
                                .foregroundColor(.orange)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }

                    NavigationLink {
                        DayActionPickerView(onComplete: {
                            onComplete()
                        })
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Choose my actions…")
                                    .font(.headline)
                                Text("Pick which actions you want today and how many of each.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "checklist")
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Plan your day")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
