//
//  ActionEditView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-04.
//

import SwiftUI

struct ActionNewView: View {
    @EnvironmentObject private var vm : ActionViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var actionTitle: String = "Breathe"
    @State private var actionDuration = 5
    @State private var isQuantifiable = false
    @State private var quantityUnit: String = ""
    @State private var defaultQuantity: Int = 1
    
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

                HStack {
                    Spacer()
                    Button(action: {
                        vm.add(
                            action: actionTitle,
                            duration: actionDuration,
                            isQuantifiable: isQuantifiable,
                            unit: quantityUnit.isEmpty ? nil : quantityUnit,
                            defaultQuantity: isQuantifiable ? defaultQuantity : nil
                        )
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 15){
                            Text("Save")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: 260)
                        .background(Color.green)
                        .clipShape(Capsule())
                        .shadow(radius: 5)

                    }
                    Spacer()
                }
            }
            .padding(24)
        }
        .navigationBarTitle("New Action")
        .navigationBarTitleDisplayMode(.inline)
    }
    
}
