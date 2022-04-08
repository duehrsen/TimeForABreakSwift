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
    @StateObject private var notificationManager = NotificationManager()
    
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
                .tabViewStyle(.page)
        }
        .onAppear {
            notificationManager.reloadAuthorizationStatus()
            allActions.load { result in
                switch result {
                case .failure( let error):
                    print(error.localizedDescription)
                    allActions.restoreDefaultsToDisk()
                case .success(let loadedActions):
                    allActions.actions = loadedActions
                }
            }
            selectActions.load { result in
                switch result {
                case .failure( let error):
                    print(error.localizedDescription)
                    selectActions.emptyData()
                case .success(let loadedActions):
                    selectActions.actions = loadedActions
                }
            }
            allActions.addActivityFromApi()
        }
        .onChange(of: notificationManager.authorizationStatus, perform: { authorizationStatus in
            switch authorizationStatus {
            case .notDetermined:
                notificationManager.requestAuth()
                print("request auth")
            case .authorized:
                notificationManager.reloadLocNotifications()
                print("reload notif")
                
            default:
                break
            }
        })
        .environmentObject(tM)
        .environmentObject(selectActions)
        .environmentObject(allActions)
        .environmentObject(notificationManager)
        .edgesIgnoringSafeArea(.bottom)

    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
