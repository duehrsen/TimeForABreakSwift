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
                
                Stepper("\(actionDuration) min", value: $actionDuration, in: 1...10, step: 1) {_ in
                }
                
                Divider()
            }
            
            HStack {
                Button {
                    vm.update(id: action.id, newtitle: actionTitle, duration: actionDuration)
                } label: {
                    HStack {
                        Text("Save")
                    }
                    .foregroundColor(.green)
                }
                Spacer()
                
                
                Button {
                    vm.deleteById(id: action.id)
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack {
                        Text("Delete")
                    }
                    .foregroundColor(.red)
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


//struct ActionEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActionEditView()
//    }
//}
