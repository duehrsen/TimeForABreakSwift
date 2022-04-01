//
//  ContentView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-21.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var timerModel = TimerModel()
    
    @State private var action: Int? = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Text("time \(timerModel.workTimeTotalSeconds)")
                NavigationLink(destination: TimerCountView(timerModel: timerModel)) {
                    Text("START")
                }
                .buttonStyle(StandardButton())
                NavigationLink(destination: ActionListView()) {
                    Text("ACTIONS")
                }
                .buttonStyle(StandardButton())
                NavigationLink(destination: OptionsView(workMinutes: timerModel.workTimeTotalSeconds/60, breakMinutes: timerModel.breakTimeTotalSeconds/60)) {
                    Text("OPTIONS")
                }
                .buttonStyle(StandardButton())
            }
        }
        .environmentObject(timerModel)

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
