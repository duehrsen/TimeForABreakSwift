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

    @State private var selectionCounts: [UUID: Int] = [:]

    private func bindingForAction(_ action: BreakAction) -> Binding<Bool> {
        Binding(
            get: {
                (selectionCounts[action.id] ?? 0) > 0
            },
            set: { newValue in
                if newValue {
                    if selectionCounts[action.id] == nil || selectionCounts[action.id] == 0 {
                        selectionCounts[action.id] = 1
                    }
                } else {
                    selectionCounts[action.id] = nil
                }
            }
        )
    }

    private func countBinding(for action: BreakAction) -> Binding<Int> {
        Binding(
            get: {
                max(selectionCounts[action.id] ?? 1, 1)
            },
            set: { newValue in
                selectionCounts[action.id] = max(newValue, 1)
            }
        )
    }

    private func applySelection() {
        var templates: [BreakAction] = []
        for action in allActions.actions {
            guard let count = selectionCounts[action.id], count > 0 else { continue }
            for _ in 0..<count {
                templates.append(action)
            }
        }
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

                        if (selectionCounts[action.id] ?? 0) > 0 {
                            Stepper(
                                value: countBinding(for: action),
                                in: 1...10
                            ) {
                                Text("×\(selectionCounts[action.id] ?? 1)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 100)
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
                .disabled(selectionCounts.values.allSatisfy { $0 <= 0 })
            }
        }
    }
}
