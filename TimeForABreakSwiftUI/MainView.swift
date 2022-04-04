//
//  MainView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-03.
//

import SwiftUI

struct MainView: View {
    
    @StateObject var tM = TimerModel()
    @StateObject var selectActions = SelectedActionsViewModel()
    @StateObject var allActions = ActionViewModel()
    
    var body: some View {
        TabView{
            TimerCountView()
                .tabItem {
                    Label("Timer", systemImage: "clock.circle.fill")
                }
            ActionListView()
                .tabItem {
                    Label("Action List", systemImage:"list.bullet.circle.fill")
                }
            OptionsView(workMinutes: tM.workTimeTotalSeconds/60, breakMinutes: tM.breakTimeTotalSeconds/60)
                .tabItem {
                    Label("Options", systemImage: "gearshape.fill")
                }

        }
        .environmentObject(tM)
        .environmentObject(selectActions)
        .environmentObject(allActions)

    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
