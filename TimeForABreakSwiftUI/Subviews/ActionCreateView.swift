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
    @State private var actionTitle: String = ""
    @State private var actionDuration = 5
    
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
            
            HStack {
                Button {
                    vm.add(action: actionTitle, duration: actionDuration)
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack {
                        Text("Save")
                    }
                    .foregroundColor(.green)
                }          
            

            
        }
        .navigationBarTitle("Create New Action")
        .navigationBarTitleDisplayMode(.inline)
        .padding(24)
            Spacer()
    }
    
}
}
