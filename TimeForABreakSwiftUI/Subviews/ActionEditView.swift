//
//  ActionEditView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-04.
//

import SwiftUI

struct ActionEditView: View {
    @EnvironmentObject private var vm: ActionViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var actionTitle: String = ""
    @State private var actionDuration = 5
    @State private var isQuantifiable = false
    @State private var quantityUnit: String = ""
    @State private var defaultQuantity: Int = 1

    @State private var lastSavedTitle: String = ""
    @State private var lastSavedDuration: Int = 5
    @State private var lastSavedQuantifiable: Bool = false
    @State private var lastSavedUnit: String = ""
    @State private var lastSavedDefaultQty: Int = 1

    @State private var showUpdatedToast = false
    @State private var debounceTask: Task<Void, Never>?

    let action: BreakAction

    private var trimmedTitle: String {
        actionTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var hasChangesFromLastSave: Bool {
        trimmedTitle != lastSavedTitle
            || actionDuration != lastSavedDuration
            || isQuantifiable != lastSavedQuantifiable
            || quantityUnit.trimmingCharacters(in: .whitespacesAndNewlines) != lastSavedUnit
            || defaultQuantity != lastSavedDefaultQty
    }

    private func captureLastSavedFromDraft() {
        lastSavedTitle = trimmedTitle
        lastSavedDuration = actionDuration
        lastSavedQuantifiable = isQuantifiable
        lastSavedUnit = quantityUnit.trimmingCharacters(in: .whitespacesAndNewlines)
        lastSavedDefaultQty = defaultQuantity
    }

    private func persistIfNeeded(showToast: Bool) {
        guard hasChangesFromLastSave, !trimmedTitle.isEmpty else { return }
        vm.update(
            id: action.id,
            newtitle: trimmedTitle,
            duration: actionDuration,
            isQuantifiable: isQuantifiable,
            unit: quantityUnit.isEmpty ? nil : quantityUnit,
            defaultQuantity: isQuantifiable ? defaultQuantity : nil
        )
        captureLastSavedFromDraft()
        if showToast {
            showUpdatedToast = true
        }
    }

    private func scheduleDebouncedPersist() {
        debounceTask?.cancel()
        debounceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            persistIfNeeded(showToast: true)
        }
    }

    var body: some View {

        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                VStack(alignment: .leading, spacing: 4) {
                    Text("Duration")
                        .foregroundColor(.gray)

                    Stepper("\(actionDuration) min", value: $actionDuration, in: 1...60, step: 1) { _ in }

                    Divider()

                    Text("Action")
                        .foregroundColor(.gray)

                    TextEditor(text: $actionTitle)
                        .padding(.horizontal)
                        .frame(height: 100)
                    Divider()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Tracking")
                        .foregroundColor(.gray)

                    Toggle("Track a quantity (e.g. reps, cups, minutes)", isOn: $isQuantifiable)

                    if isQuantifiable {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Unit (e.g. reps, cups, minutes)", text: $quantityUnit)
                                .textFieldStyle(.roundedBorder)

                            Stepper("Default amount: \(defaultQuantity)", value: $defaultQuantity, in: 1...100)
                        }
                        .padding(.leading)
                    }
                }

                Button(action: {
                    vm.deleteById(id: action.id)
                    debounceTask?.cancel()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 15) {
                        Text("Delete")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .clipShape(Capsule())
                    .shadow(radius: 5)
                }
            }
            .padding(24)
        }
        .navigationBarTitle("Edit Action")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: {
            actionTitle = action.title
            actionDuration = action.duration
            isQuantifiable = action.isQuantifiable
            quantityUnit = action.unit ?? ""
            defaultQuantity = action.defaultQuantity ?? 1
            captureLastSavedFromDraft()
        })
        .onChange(of: actionTitle) { _ in scheduleDebouncedPersist() }
        .onChange(of: actionDuration) { _ in scheduleDebouncedPersist() }
        .onChange(of: isQuantifiable) { _ in scheduleDebouncedPersist() }
        .onChange(of: quantityUnit) { _ in scheduleDebouncedPersist() }
        .onChange(of: defaultQuantity) { _ in scheduleDebouncedPersist() }
        .onDisappear {
            debounceTask?.cancel()
            persistIfNeeded(showToast: true)
        }
        .toast(
            message: "Action updated",
            isShowing: $showUpdatedToast,
            config: .init(
                backgroundColor: .green.opacity(0.85),
                sysImg: "checkmark.circle.fill"
            )
        )
    }
}
