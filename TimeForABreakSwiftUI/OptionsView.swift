//
//  OptionsView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-31.
//

import SwiftUI

struct OptionsView: View {
    @EnvironmentObject var timerModel: TimerModel
    var workMinutes : Int
    var breakMinutes : Int
    
    var body: some View {
        VStack {
            Text("Work time")
                .font(.title2)
            Stepper("\(workMinutes) minutes", value: $timerModel.workTimeTotalSeconds, in: 2...4000, step: 60) {_ in

            }
            .frame(width: 200)
            
            Text("Break time")
                .font(.title2)
            Stepper("\(breakMinutes) minutes", value: $timerModel.breakTimeTotalSeconds, in: 0...1000, step: 60) {_ in
                
            }
            .frame(width: 200)
        }
    }
}
