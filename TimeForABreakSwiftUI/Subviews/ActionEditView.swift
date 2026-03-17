//
//  ActionEditView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-04.
//

import SwiftUI

struct ActionEditView: View {
    @EnvironmentObject private var vm : ActionViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var actionTitle: String = ""
    @State private var actionDuration = 5
    @State private var isQuantifiable = false
    @State private var quantityUnit: String = ""
    @State private var defaultQuantity: Int = 1
    
    let action: BreakAction
       
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

                HStack(alignment: .center, spacing: 10) {
                    Button(action: {
                        vm.update(
                            id: action.id,
                            newtitle: actionTitle,
                            duration: actionDuration,
                            isQuantifiable: isQuantifiable,
                            unit: quantityUnit.isEmpty ? nil : quantityUnit,
                            defaultQuantity: isQuantifiable ? defaultQuantity : nil
                        )
                    }) {
                        HStack(spacing: 15){
                            Text("Save")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .clipShape(Capsule())
                        .shadow(radius: 5)

                    }

                    Button(action: {
                        vm.deleteById(id: action.id)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 15){
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
        })
    }
        
    }
