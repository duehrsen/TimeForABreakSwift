//
//  OptionsView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-31.
//

import SwiftUI

struct OptionsView: View {
    @EnvironmentObject var tM: TimerModel
    var workMinutes : Int
    var breakMinutes : Int
    var actionVM : ActionViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Work time")
                    .font(.title2)
                Stepper("\(workMinutes) minutes", value: $tM.workTimeTotalSeconds, in: 0...4000, step: 60) {_ in
                    tM.resetTimer()
                }
                //.frame(width: 200)
                
                Text("Break time")
                    .font(.title2)
                Stepper("\(breakMinutes) minutes", value: $tM.breakTimeTotalSeconds, in: 0...1000, step: 60) {_ in
                    tM.resetTimer()
                }
                //.frame(width: 200)
                Spacer()
                
                Button(action: {
                    actionVM.restoreDefaultsToDisk()
                }) {
                    HStack(spacing: 15){
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.white)
                        Text("Restore defaults")
                            .font(.body)
                            .foregroundColor(.white)
                    }
                    
                } .buttonStyle(FlatWideButtonStyle(bgColor: .red))
                Spacer()
                
            }.navigationBarTitle("App Options")
        }
    }
}
