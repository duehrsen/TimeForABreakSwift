//
//  ContentView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-21.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var timerModel = TimerModel()
    @StateObject var selectActions = SelectedActionsViewModel()
    @StateObject var allActions = ActionViewModel()
    
    @State private var action: Int? = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Time for a Break")
                    .font(.custom("Kailasa", size: 40))
                NavigationLink(destination: TimerCountView()) {
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
        .environmentObject(selectActions)
        .environmentObject(allActions)

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
