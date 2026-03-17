//
//  DayActionPickerView.swift
//  TimeForABreakSwiftUI
//

import SwiftUI

struct DayActionPickerView: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject var allActions: ActionViewModel
    @EnvironmentObject var selectActions: SelectedActionsViewModel

    /// Called after today's actions have been set.
    let onComplete: () -> Void

    @State private var selectedIds: Set<UUID> = []

    private func bindingForAction(_ action: BreakAction) -> Binding<Bool> {
        Binding(
            get: { selectedIds.contains(action.id) },
            set: { newValue in
                if newValue {
                    selectedIds.insert(action.id)
                } else {
                    selectedIds.remove(action.id)
                }
            }
        )
    }

    private func applySelection() {
        let templates = allActions.actions.filter { selectedIds.contains($0.id) }
        guard !templates.isEmpty else {
            dismiss()
            return
        }
        selectActions.setTodaysActions(from: templates)
        onComplete()
        dismiss()
    }

    var body: some View {
        List {
            Section("Select actions for today") {
                ForEach(allActions.actions, id: \.id) { action in
                    HStack {
                        Toggle(isOn: bindingForAction(action)) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(action.title)
                                    .font(.body)
                                if !action.description.isEmpty {
                                    Text(action.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Choose actions")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    applySelection()
                }
                .disabled(selectedIds.isEmpty)
            }
        }
    }
}
