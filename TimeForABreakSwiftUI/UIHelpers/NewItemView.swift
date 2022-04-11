//
//  NewItemView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-10.
//

import SwiftUI

struct NewItemView: View {
    
    let defaultTime : Int = 3
    
    @EnvironmentObject var allActionsVM : ActionViewModel
    @State private var actionString = ""
    @State private var durationValue = 5
    
    var body: some View {
        
        VStack {
            HStack {
                Spacer()
                TextField("New action", text: $actionString)
                    .frame(height: 40, alignment: .center)
                    .padding(.horizontal, 5)
                    .foregroundColor(Color.black)
                    .background(Color.white)
                    .border(Color.secondary)
                    .multilineTextAlignment(TextAlignment.center)
                Spacer()
                Button(action: {
                    let actStr = actionString.trimmingCharacters(in: .whitespaces)
                    if (actStr.count > 0)
                    {
                        allActionsVM.add(action: actionString, duration: durationValue > 0 ? durationValue : defaultTime)
                        actionString = ""
                        durationValue = defaultTime
                    }
                }) {
                    Label("", systemImage: "plus.app.fill")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                }
            }
            Stepper("\(durationValue) min", value: $durationValue, in: 1...60, step: 1) {_ in
            }.frame(width: UIScreen.main.bounds.width - 60, alignment: .center)

        }
        //.background(Color.secondary)
        
        
    }
}
