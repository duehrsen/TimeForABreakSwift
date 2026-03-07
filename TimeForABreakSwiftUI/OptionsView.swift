//
//  OptionsView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-31.
//

import SwiftUI

struct OptionsView: View {
    @EnvironmentObject var timerModel: TimerModel
    @EnvironmentObject var optionsModel : OptionsModel
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
            VStack {
                Spacer()
                OptionsInputSubView()
                Spacer()
                
                HStack(alignment: .center, spacing: 10) {
                    Button(action: {
                        if optionsModel.options.worktimeMin > 0 && optionsModel.options.breaktimeMin > 0 {
                            let newOptions = OptionSet(breaktimeMin: optionsModel.options.breaktimeMin, worktimeMin: optionsModel.options.worktimeMin, doesPlaySounds: optionsModel.options.doesPlaySounds, isMuted: optionsModel.options.isMuted)
                            Task {
                                try? await optionsModel.save(options: newOptions)
                            }
                            timerModel.updateFromOptions(optionSet: newOptions)
                        }
                    }) {
                        HStack(spacing: 15){
                            Text("Save")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(width: geometry.size.width / 2 - 20)
                        .background(Color.green)
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                        
                    }
                    
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolbars(title: "Options")

                }
        

                Spacer()
                
            }
            }
        }
    }
}
