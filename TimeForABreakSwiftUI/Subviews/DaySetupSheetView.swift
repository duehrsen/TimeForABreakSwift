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
    
    @State private var showNoSuggestionsAlert: Bool = false

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

    private func useSuggestedSet() {
        let templates = buildSuggestedTemplates()
        guard !templates.isEmpty else {
            showNoSuggestionsAlert = true
            return
        }
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
                    Button(action: useSuggestedSet) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Use my default break plan")
                                    .font(.headline)
                                Text("Start from your saved suggestion set. You can change this in Options.")
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

                    Text("You can edit this in Options → Planning → Set a default day’s actions.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)

                    NavigationLink {
                        DayActionPickerView(onComplete: {
                            onComplete()
                        })
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Choose my actions…")
                                    .font(.headline)
                                Text("Pick which break actions you want to focus on today.")
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
            .alert("No suggested actions yet", isPresented: $showNoSuggestionsAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Add some break actions, then choose Set a default day’s actions under Options → Planning.")
            }
        }
    }
}
