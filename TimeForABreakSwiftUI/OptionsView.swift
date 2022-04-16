//
//  OptionsView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-31.
//

import SwiftUI

struct OptionsView: View {
    @EnvironmentObject var tM: TimerModel
    @EnvironmentObject var os : OptionsModel
    @State private var playSounds : Bool = false
    @State private var workMin : Int = 60
    @State private var breakMin: Int = 5
    private var actionVM : ActionViewModel = ActionViewModel()
    
    var body: some View {
        NavigationView {
            VStack {                
//                HStack {
//                    Text("Adjust your time intervals")
//                        .padding()
//                    Spacer()
//                }
                Spacer()
                OptionsInputSubView()
                Spacer()
                
                HStack(alignment: .center, spacing: 10) {
                    Button(action: {
                        if os.options.worktimeMin > 0 && os.options.breaktimeMin > 0 {
                            let newOptions = OptionSet(breaktimeMin: os.options.breaktimeMin, worktimeMin: os.options.worktimeMin, doesPlaySounds: os.options.doesPlaySounds)
                            print("gonna save")
                            os.save(options: newOptions) { result in
                                if case .failure(let error) = result {
                                    fatalError(error.localizedDescription)
                                }
                            }
                            tM.updateFromOptions(optionSet: newOptions)
                        }
                    }) {
                        HStack(spacing: 15){
                            Text("Save")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(width: UIScreen.main.bounds.width/2 - 20)
                        .background(Color.green)
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                        
                    }
                    
                    Button(action: {
                        actionVM.restoreDefaultsToDisk()
                        os.setDefault()
                    }) {
                        HStack(spacing: 15){
                            //Image(systemName: "rectangle.portrait.and.arrow.right")                              .foregroundColor(.white)
                            Text("Restore all")
                                .font(.body)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(width: UIScreen.main.bounds.width/2 - 20)
                        .background(Color.red)
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                    }
                    
                }
                //.navigationBarTitle("App Options")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolbars(title: "Options")

                }
        

                Spacer()
                
            }
        }
    }
}
