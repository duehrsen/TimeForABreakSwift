//
//  ActionEditView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-04.
//

import SwiftUI

struct ActionCreateView: View {
    @EnvironmentObject private var vm : ActionViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var actionTitle: String = "Type here"
    @State private var actionDuration = 5
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 24) {
            
            VStack(spacing: 4) {
                Text("Duration")
                    .foregroundColor(.gray)
                
                Stepper("\(actionDuration) min", value: $actionDuration, in: 1...60, step: 1) {_ in
                }
                .frame(width: (UIScreen.main.bounds.width - 100), alignment: .center)
                
                Divider()
                
                Text("Action").foregroundColor(.gray)
                
                TextEditor(text: $actionTitle)
                    .padding(.horizontal)
                    .navigationTitle("Action")
                    .frame(height: 100)
                Divider()
                
            }
            
            
            VStack() {
                HStack(alignment: .center, spacing: 10) {
                    Button(action: {
                        vm.add(action: actionTitle, duration: actionDuration)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 15){
                            Spacer()
                            //Image(systemName: "checkmark.circle.fill")        .foregroundColor(.white)
                            Text("Save")
                                .foregroundColor(.white)
                            //.font(.caption)
                            Spacer()
                        }
                        .padding()
                        .background(Color.green)
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                        
                    }
                    
                }
                .navigationBarTitle("Create New Action")
                .navigationBarTitleDisplayMode(.inline)
                .padding(24)
            }
            Spacer()
        }
        
    }
}
