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
    @StateObject private var liveActivityManager = LiveActivityManager()
    
    @State private var switchedToBackground : Bool = false
    @State private var selectedTab = 0
    @State private var minDragForSwipe : CGFloat = 60
    @State private var showDaySetupSheet: Bool = false
    @State private var showDaySummarySheet: Bool = false
    
    let numTabs = 3
    
    private func handleSwipe(translation : CGFloat) {
    }

    private func nextActionPreview() -> String {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())

        let suggestedTitles: Set<String>
        if let titles = optionsModel.options.dailySuggestedTitles,
           !titles.isEmpty {
            suggestedTitles = Set(titles)
        } else {
            suggestedTitles = Set(DataProvider.defaultDailySuggestedActionTitles())
        }

        let uncompletedTodayOrPinned = selectActions.actions.filter {
            (cal.isDate($0.date ?? .distantPast, inSameDayAs: today) || $0.pinned) && !$0.completed
        }

        if let suggestedNext = uncompletedTodayOrPinned.first(where: { suggestedTitles.contains($0.title) }) {
            return "Next: \(suggestedNext.title)"
        }

        if let anyNext = uncompletedTodayOrPinned.first {
            return "Next: \(anyNext.title)"
        }

        return "Focus time"
    }

    private func markDaySetupDone() {
        let today = Calendar.current.startOfDay(for: Date())
        UserDefaults.standard.set(today, forKey: "lastDaySetupDate")
        showDaySetupSheet = false
        showDaySummarySheet = true
    }

    private func evaluateDaySetupIfNeeded() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        if let last = UserDefaults.standard.object(forKey: "lastDaySetupDate") as? Date {
            if !cal.isDate(last, inSameDayAs: today) {
                showDaySetupSheet = true
            }
        } else {
            showDaySetupSheet = true
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab ) {
            TimerCountView()
                .tabItem {
                    Label("Timer", systemImage: "hourglass.circle")
                }
                .tag(0)
            SummaryView()
                .tabItem {
                    Label("Summary", systemImage: "clock.badge.checkmark.fill")
                }
                .tag(1)
            
            OptionsView()
                .tabItem {
                    Label("Options", systemImage: "gearshape.fill")
                }
                .tag(2)
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
                            doesPlaySounds: !optionsModel.options.isMuted) { error in
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
                    if timerModel.started {
                        liveActivityManager.updateActivity(
                            isWorkTime: timerModel.isWorkTime,
                            isRunning: true,
                            timeRemaining: timerModel.currentTimeRemaining,
                            totalSeconds: timerModel.totalSecondsForCurrentMode
                        )
                    }
                @unknown default:
                    break
                }
        }
        .task {
            notificationManager.reloadAuthorizationStatus()
            do {
                let loadedActions = try await allActions.load()
                if loadedActions.count > 0 {
                    allActions.actions = DataMigration.migrateCategories(in: loadedActions)
                } else {
                    allActions.restoreDefaultsToDisk()
                }
            } catch {
                allActions.restoreDefaultsToDisk()
            }
            do {
                let loadedActions = try await selectActions.load()
                selectActions.actions = DataMigration.migrateCategories(in: loadedActions)
            } catch {
                selectActions.emptyData()
            }
            do {
                let loadedCompletions = try await selectActions.loadCompletions()
                selectActions.completions = loadedCompletions
            } catch {
                selectActions.completions = []
            }
            allActions.addActivityFromApi()
            do {
                let loadedOptions = try await optionsModel.load()
                optionsModel.options = loadedOptions
                optionsModel.updateOptionsModel(breakMin: loadedOptions.breaktimeMin, workMin: loadedOptions.worktimeMin, doesPlaySounds: loadedOptions.doesPlaySounds, isMuted: loadedOptions.isMuted)
                timerModel.updateFromOptions(optionSet: loadedOptions)
            } catch {
                optionsModel.setDefault()
            }
            evaluateDaySetupIfNeeded()
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
        .onChange(of: timerModel.started) { isStarted in
            if isStarted {
                liveActivityManager.startActivity(
                    isWorkTime: timerModel.isWorkTime,
                    timeRemaining: timerModel.currentTimeRemaining,
                    totalSeconds: timerModel.totalSecondsForCurrentMode,
                    actionPreview: nextActionPreview()
                )
            } else if !timerModel.isComplete {
                liveActivityManager.updateActivity(
                    isWorkTime: timerModel.isWorkTime,
                    isRunning: false,
                    timeRemaining: timerModel.currentTimeRemaining,
                    totalSeconds: timerModel.totalSecondsForCurrentMode
                )
            }
        }
        .onChange(of: timerModel.isComplete) { isComplete in
            if isComplete {
                liveActivityManager.endActivity()
            }
        }
        .onChange(of: timerModel.isWorkTime) { _ in
            liveActivityManager.endActivity()
        }
        .onOpenURL { url in
            guard url.scheme == "timeforabreak", url.host == "voice" else { return }
            selectedTab = 0
        }
        .sheet(isPresented: $showDaySetupSheet) {
            DaySetupSheetView(
                onComplete: { markDaySetupDone() }
            )
            .environmentObject(selectActions)
            .environmentObject(allActions)
            .environmentObject(optionsModel)
        }
        .sheet(isPresented: $showDaySummarySheet) {
            DayPlanSummaryView()
                .environmentObject(selectActions)
                .onDisappear {
                    showDaySummarySheet = false
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
