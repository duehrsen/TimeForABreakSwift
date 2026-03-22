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
    @State private var showDaySetupSheet: Bool = false
    @State private var showDaySummarySheet: Bool = false
    @State private var showWelcomeSheet: Bool = false
    @State private var showNotificationPrePrompt: Bool = false
    
    private func nextActionPreview() -> String {
        NextActionPreview.line(options: optionsModel.options, actions: selectActions.actions)
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

    /// Avoid stacking the notification alert on the welcome sheet (that dismisses the sheet). Call after welcome completes.
    private func maybeShowNotificationPrePromptIfNeeded() {
        guard UserDefaults.standard.bool(forKey: "hasSeenWelcome") else { return }
        let hasShownPrePrompt = UserDefaults.standard.bool(forKey: "hasShownNotificationPrePrompt")
        guard !hasShownPrePrompt else { return }

        switch notificationManager.authorizationStatus {
        case .some(.notDetermined):
            showNotificationPrePrompt = true
        case .none:
            notificationManager.reloadAuthorizationStatus()
        default:
            break
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
                            doesPlaySounds: optionsModel.options.completionFeedback == .sound) { error in
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
                    if timerModel.started, optionsModel.options.liveActivityEnabled {
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
            do {
                let loadedOptions = try await optionsModel.load()
                optionsModel.options = loadedOptions
                timerModel.updateFromOptions(optionSet: loadedOptions)
            } catch {
                optionsModel.setDefault()
            }
            let hasSeenWelcome = UserDefaults.standard.bool(forKey: "hasSeenWelcome")
            if hasSeenWelcome {
                evaluateDaySetupIfNeeded()
            } else {
                // Present on the next turn so startup state updates (e.g. notification status) don’t fight this sheet.
                await Task.yield()
                showWelcomeSheet = true
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
            // Don’t present the alert over welcome / day setup / summary — competing modals dismiss the alert.
            guard UserDefaults.standard.bool(forKey: "hasSeenWelcome") else { return }
            guard !showWelcomeSheet && !showDaySetupSheet && !showDaySummarySheet else { return }
            switch newStatus {
            case .notDetermined:
                let hasShownPrePrompt = UserDefaults.standard.bool(forKey: "hasShownNotificationPrePrompt")
                if !hasShownPrePrompt {
                    showNotificationPrePrompt = true
                }
            case .authorized:
                notificationManager.reloadLocNotifications()

            default:
                break
            }
        }
        .onChange(of: timerModel.started) { isStarted in
            if !optionsModel.options.liveActivityEnabled {
                if isStarted {
                    liveActivityManager.endActivity()
                }
                return
            }
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
            if isComplete, optionsModel.options.liveActivityEnabled {
                liveActivityManager.showTimerFinishedThenEnd(
                    isWorkTime: timerModel.isWorkTime,
                    totalSeconds: timerModel.totalSecondsForCurrentMode
                )
            }
        }
        .onChange(of: timerModel.isWorkTime) { _ in
            liveActivityManager.endActivity()
        }
        .onChange(of: optionsModel.options.liveActivityEnabled) { enabled in
            if !enabled {
                liveActivityManager.endActivity()
            } else if timerModel.started {
                liveActivityManager.startActivity(
                    isWorkTime: timerModel.isWorkTime,
                    timeRemaining: timerModel.currentTimeRemaining,
                    totalSeconds: timerModel.totalSecondsForCurrentMode,
                    actionPreview: nextActionPreview()
                )
            }
        }
        .onOpenURL { url in
            guard url.scheme == "timeforabreak", url.host == "voice" else { return }
            selectedTab = 0
        }
        .sheet(isPresented: $showDaySetupSheet, onDismiss: {
            // If user completed setup, day summary is about to show (or is showing)—prompt after summary instead.
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 450_000_000)
                guard !showDaySummarySheet else { return }
                maybeShowNotificationPrePromptIfNeeded()
            }
        }) {
            DaySetupSheetView(
                onComplete: { markDaySetupDone() }
            )
            .environmentObject(selectActions)
            .environmentObject(allActions)
            .environmentObject(optionsModel)
        }
        .sheet(isPresented: $showDaySummarySheet, onDismiss: {
            maybeShowNotificationPrePromptIfNeeded()
        }) {
            DayPlanSummaryView()
                .environmentObject(selectActions)
        }
        .sheet(isPresented: $showWelcomeSheet, onDismiss: {
            UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
            evaluateDaySetupIfNeeded()
        }) {
            WelcomeSheetView()
        }
        .environmentObject(optionsModel)
        .environmentObject(timerModel)
        .environmentObject(selectActions)
        .environmentObject(allActions)
        .environmentObject(notificationManager)
        .edgesIgnoringSafeArea(.bottom)
        .alert("Allow break reminders?", isPresented: $showNotificationPrePrompt) {
            Button("Not now", role: .cancel) {
                UserDefaults.standard.set(true, forKey: "hasShownNotificationPrePrompt")
            }
            Button("Allow reminders") {
                UserDefaults.standard.set(true, forKey: "hasShownNotificationPrePrompt")
                notificationManager.requestAuth()
            }
        } message: {
            Text("Time For A Break can notify you when work or breaks end.")
        }

    }
}
