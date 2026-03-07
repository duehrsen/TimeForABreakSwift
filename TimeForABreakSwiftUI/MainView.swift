//
//  MainView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-03.
//

import SwiftUI

struct MainView: View {
    
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var timerModel = TimerModel()
    @StateObject var selectActions = SelectedActionsViewModel()
    @StateObject var allActions = ActionViewModel()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject var optionsModel = OptionsModel()
    
    @State private var switchedToBackground : Bool = false
    @State private var selectedTab = 0
    @State private var minDragForSwipe : CGFloat = 60
    
    let numTabs = 4
    
    private func handleSwipe(translation : CGFloat) {
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
            SummaryView()
                .tabItem {
                    Label("Summary", systemImage: "clock.badge.checkmark.fill")
                }
                .tag(2)
            
            OptionsView()
                .tabItem {
                    Label("Options", systemImage: "gearshape.fill")
                }
                .tag(3)
                .highPriorityGesture(DragGesture().onEnded({ self.handleSwipe(translation: $0.translation.width) }))
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
                case .background, .inactive:
                if !switchedToBackground {
                    switchedToBackground = true
                    timerModel.movingToBackground()
                    notificationManager.cancelAllNotifications()
                    if timerModel.started
                    {
                        notificationManager.createLocalNotification(
                            title: timerModel.isWorkTime ? "Time for a break!" : "Break time's over",
                            body: timerModel.isWorkTime ? "You worked for \(timerModel.workTimeTotalSeconds/60) min" : "\(timerModel.breakTimeTotalSeconds/60) min break over.",
                            secondsUntilDone: timerModel.currentTimeRemaining,
                            doesPlaySounds: optionsModel.options.doesPlaySounds) { error in
                            if error == nil {
                                DispatchQueue.main.async {
                                    notificationManager.reloadLocNotifications()
                                }
                            }
                        }
                        
                    }
                }


                
                case .active:
                    switchedToBackground = false
                    timerModel.movingToActive()
                    notificationManager.cancelAllNotifications()
                @unknown default:
                    break
                }
        }
        .task {
            notificationManager.reloadAuthorizationStatus()
            do {
                let loadedActions = try await allActions.load()
                if loadedActions.count > 0 {
                    allActions.actions = loadedActions
                } else {
                    allActions.restoreDefaultsToDisk()
                }
            } catch {
                allActions.restoreDefaultsToDisk()
            }
            do {
                let loadedActions = try await selectActions.load()
                selectActions.actions = loadedActions
            } catch {
                selectActions.emptyData()
            }
            allActions.addActivityFromApi()
            do {
                let loadedOptions = try await optionsModel.load()
                optionsModel.updateOptionsModel(breakMin: loadedOptions.breaktimeMin, workMin: loadedOptions.worktimeMin, doesPlaySounds: loadedOptions.doesPlaySounds)
                timerModel.updateFromOptions(optionSet: loadedOptions)
            } catch {
                optionsModel.setDefault()
            }
        }
        // Fetch pinned actions daily
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification), perform: { _ in
            allActions.actions.forEach { a in
                let isContained = selectActions.actions.contains { element in
                    if (element.title == a.title) {
                        return true
                    }
                    return false
                }
                
                if (a.pinned && !isContained) {
                    let newAction = BreakAction(title: a.title, description: a.description, categoryId: a.categoryId, duration: a.duration, pinned: true, completed: false, date: Date.now, linkurl: a.linkurl, frequency: a.frequency)
                    selectActions.actions.insert(newAction, at: 0)
                }
                                
            }
        })
        .onChange(of: notificationManager.authorizationStatus) { newStatus in
            switch newStatus {
            case .notDetermined:
                notificationManager.requestAuth()
            case .authorized:
                notificationManager.reloadLocNotifications()
                
            default:
                break
            }
        }
        .environmentObject(optionsModel)
        .environmentObject(timerModel)
        .environmentObject(selectActions)
        .environmentObject(allActions)
        .environmentObject(notificationManager)
        .edgesIgnoringSafeArea(.bottom)

    }
}
