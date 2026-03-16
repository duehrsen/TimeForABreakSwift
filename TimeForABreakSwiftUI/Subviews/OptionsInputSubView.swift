//
//  OptionsInputSubView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-16.
//

import SwiftUI

struct OptionsInputSubView: View {

    @EnvironmentObject var optionsModel: OptionsModel

    var body: some View {
        Text("Work time")
            .font(.title2)
        Stepper("\(optionsModel.options.worktimeMin) min", value: $optionsModel.options.worktimeMin, in: 1...60, step: 1)
            .frame(width: 250)
        Divider()

        Text("Break time")
            .font(.title2)
        Stepper("\(optionsModel.options.breaktimeMin) min", value: $optionsModel.options.breaktimeMin, in: 1...40, step: 1)
            .frame(width: 250)

        Divider()

        Toggle("Mute all audio", isOn: $optionsModel.options.isMuted)
            .frame(width: 250)
        Divider()
    }
}

