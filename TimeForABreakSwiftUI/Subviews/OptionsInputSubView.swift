//
//  OptionsInputSubView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-16.
//

import SwiftUI

struct OptionsInputSubView: View {
    
    @EnvironmentObject var os : OptionsModel
    
    var body: some View {
        Text("Work time")
            .font(.title2)
        Stepper("\(os.options.worktimeMin) min", value: $os.options.worktimeMin, in: 1...60, step: 1) {_ in
            //tM.resetTimer()
        }.frame(width: 250)
        Divider()
        
        Text("Break time")
            .font(.title2)
        Stepper("\(os.options.breaktimeMin) min", value: $os.options.breaktimeMin, in: 1...40, step: 1) {_ in
            //tM.resetTimer()
        }.frame(width: 250)
        
        Divider()
        
        Toggle("Enable sound notifications", isOn: $os.options.doesPlaySounds)
            .frame(width: 250)
        Divider()

    }
}
