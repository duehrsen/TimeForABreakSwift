//
//  MainView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-03.
//

import SwiftUI

struct MainView: View {
    
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var tM = TimerModel()
    @StateObject var selectActions = SelectedActionsViewModel()
    @StateObject var allActions = ActionViewModel()
    @StateObject private var notificationManager = NotificationManager()
    
    @State private var selectedTab = 0
    @State private var minDragForSwipe : CGFloat = 60
    
    let numTabs = 4
    
    private func handleSwipe(translation : CGFloat) {
        print("Swipey swiping, how much? \(translation) swipey!")
    }
    
    var body: some View {
        TabView(selection: $selectedTab ) {
            TimerCountView()
                .tabItem {
                    Label("Timer", systemImage: "hourglass.circle")
                }
                .tag(0)
            ActionListView()
                .tabItem {
                    Label("Action List", systemImage:"list.bullet.circle.fill")
                }
                .tag(1)
            OptionsView(workMinutes: tM.workTimeTotalSeconds/60, breakMinutes: tM.breakTimeTotalSeconds/60, actionVM: allActions)
                .tabItem {
                    Label("Options", systemImage: "gearshape.fill")
                }
                .tag(2)
            SummaryView()
                .tabItem {
                    Label("Summary", systemImage: "clock.badge.checkmark.fill")
                }
                .tag(3)
                .highPriorityGesture(DragGesture().onEnded({ self.handleSwipe(translation: $0.translation.width) }))
        }
        .onChange(of: scenePhase, perform: { scene in
            switch scene {
                case .background:
                print("App is in background")
                tM.movingToBackground()
                notificationManager.cancelAllNotifications()
                if tM.started
                {
                    notificationManager.createLocalNotification(
                        title: tM.isWorkTime ? "Time for a break!" : "Break time's over",
                        body: tM.isWorkTime ? "You worked for \(tM.workTimeTotalSeconds/60) min" : "\(tM.breakTimeTotalSeconds/60) min break over.",
                        secondsUntilDone: tM.currentTimeRemaining) { error in
                        if error == nil {
                            DispatchQueue.main.async {
                                print("notification triggered")
                                notificationManager.reloadLocNotifications()
                            }
                        }
                    }
                    
                }
                
                case .active:
                    print("App is active")
                    tM.movingToActive()
                    notificationManager.cancelAllNotifications()
                case .inactive:
                    print("App is inactive")
                @unknown default:
                    print("App state is unclear")
                }
            }
        )
        .onAppear {
            notificationManager.reloadAuthorizationStatus()
            allActions.load { result in
                switch result {
                case .failure( let error):
                    print(error.localizedDescription)
                    allActions.restoreDefaultsToDisk()
                case .success(let loadedActions):
                    if (loadedActions.count>0){
                        allActions.actions = loadedActions
                        print("Actions loaded from file")
                    } else {
                        allActions.restoreDefaultsToDisk()
                        print("Default actions loaded")
                    }
                    
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
