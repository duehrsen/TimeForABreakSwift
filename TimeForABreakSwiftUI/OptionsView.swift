//
//  OptionsView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-31.
//

import SwiftUI

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
        .navigationTitle("Default day’s actions")
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
