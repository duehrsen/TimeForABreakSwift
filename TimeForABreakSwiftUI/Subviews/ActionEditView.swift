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
    @State private var actionDuration = 3
    
    let action: BreakAction
       
    var body: some View {
        
        VStack(alignment: .leading, spacing: 24) {
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Action")
                    .foregroundColor(.gray)
                
                TextField("Enter title..", text: $actionTitle)
                    .font(.largeTitle)
                
                Text("Action duration")
                    .foregroundColor(.gray)
                
                Stepper("\(actionDuration) min", value: $actionDuration, in: 1...60, step: 1) {_ in
                }
                
                Divider()
            }
            
            VStack() {
                HStack(alignment: .center, spacing: 10) {
                Button(action: {
                    vm.update(id: action.id, newtitle: actionTitle, duration: actionDuration)
                }) {
                    HStack(spacing: 15){
                        //Image(systemName: "checkmark.circle.fill")        .foregroundColor(.white)
                        Text("Save")
                            .foregroundColor(.white)
                            //.font(.caption)
                    }
                    .padding()
                    .frame(width: UIScreen.main.bounds.width/2 - 20)
                    .background(Color.green)
                    .clipShape(Capsule())
                    .shadow(radius: 5)
                    
                }
                
                Button(action: {
                    vm.deleteById(id: action.id)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 15){
                        //Image(systemName: "trash.fill")    .foregroundColor(.white)
                        Text("Delete")
                            .foregroundColor(.white)
                            //.font(.caption)
                    }
                    .padding()
                    .frame(width: UIScreen.main.bounds.width/2 - 20)
                    .background(Color.red)
                    .clipShape(Capsule())
                    .shadow(radius: 5)
                }
            }
        }
            
            Spacer()
            

        }
        .navigationBarTitle("Edit Action")
        .navigationBarTitleDisplayMode(.inline)
        .padding(24)
        .onAppear(perform: {
            actionTitle = action.title
            actionDuration = action.duration
        })
    }
        
    }
