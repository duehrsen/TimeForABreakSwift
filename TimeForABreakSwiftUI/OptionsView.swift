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
    
    var body: some View {
        VStack {
            Text("App Options")
                .font(.largeTitle)
            Spacer()
            Text("Work time")
                .font(.title2)
            Stepper("\(workMinutes) minutes", value: $tM.workTimeTotalSeconds, in: 0...4000, step: 60) {_ in

            }
            .frame(width: 200)
            
            Text("Break time")
                .font(.title2)
            Stepper("\(breakMinutes) minutes", value: $tM.breakTimeTotalSeconds, in: 0...1000, step: 60) {_ in
                
            }
            .frame(width: 200)
            Spacer()
            
        }
    }
}
