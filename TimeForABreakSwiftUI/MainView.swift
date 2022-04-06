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
            OptionsView(workMinutes: tM.workTimeTotalSeconds/60, breakMinutes: tM.breakTimeTotalSeconds/60, actionVM: allActions)
                .tabItem {
                    Label("Options", systemImage: "gearshape.fill")
                }

        }
        .onAppear {
            ActionViewModel.load { result in
                switch result {
                case .failure( let error):
                    print(error.localizedDescription)
                    allActions.restoreDefaultsToDisk()
                case .success(let loadedActions):
                    allActions.actions = loadedActions
                }
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
