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

    @State private var switchedToBackground: Bool = false
    @State private var showDaySetupSheet: Bool = false
    @State private var showDaySummarySheet: Bool = false
    @State private var showWelcomeSheet: Bool = false
    @State private var showNotificationPrePrompt: Bool = false

    @State private var showCompanionSheet: Bool = false
    @State private var companionDetent: PresentationDetent = .companionCollapsed
    @State private var companionVoiceLog: Bool = false
    @State private var companionListLog: Bool = false
    @State private var showManualDayPlan: Bool = false

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

    /// Line shown on Live Activity / Dynamic Island when enabled in options.
    private func resolvedLiveActivityPreview() -> String {
        guard optionsModel.options.liveActivityEnabled,
              optionsModel.options.liveActivityShowsNextAction else { return "" }
        return nextActionPreview()
    }

    /// Reconciles Live Activity with `options` (e.g. lock screen / next-action toggles).
    private func applyLiveActivityForCurrentOptions() {
        if !optionsModel.options.liveActivityEnabled {
            liveActivityManager.endActivity()
            return
        }
        guard liveActivityManager.isActivityActive || timerModel.started else { return }
        if liveActivityManager.isActivityActive {
            liveActivityManager.updateActivity(
                isWorkTime: timerModel.isWorkTime,
                isRunning: timerModel.started,
                timeRemaining: timerModel.currentTimeRemaining,
                totalSeconds: timerModel.totalSecondsForCurrentMode,
                actionPreview: resolvedLiveActivityPreview()
            )
        } else if timerModel.started {
            liveActivityManager.startActivity(
                isWorkTime: timerModel.isWorkTime,
                timeRemaining: timerModel.currentTimeRemaining,
                totalSeconds: timerModel.totalSecondsForCurrentMode,
                actionPreview: resolvedLiveActivityPreview()
            )
        }
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
        ZStack {
            GeometryReader { geo in
                TimerCountView()
                    .padding(.bottom, geo.size.height * CompanionSheetLayout.collapsedHeightFraction)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .sheet(isPresented: $showCompanionSheet) {
            TimerCompanionSheet(
                detent: $companionDetent,
                showVoiceLog: $companionVoiceLog,
                showListLog: $companionListLog,
                showManualDayPlan: $showManualDayPlan
            )
            .environmentObject(timerModel)
            .environmentObject(optionsModel)
            .environmentObject(selectActions)
            .environmentObject(allActions)
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background, .inactive:
                if !switchedToBackground {
                    switchedToBackground = true
                    timerModel.movingToBackground()
                    notificationManager.cancelAllNotifications()
                    if timerModel.started {
                        notificationManager.createLocalNotification(
                            title: timerModel.isWorkTime ? "Time for a break!" : "Break time's over",
                            body: timerModel.isWorkTime ? "You worked for \(timerModel.workTimeTotalSeconds / 60) min" : "\(timerModel.breakTimeTotalSeconds / 60) min break over.",
                            secondsUntilDone: timerModel.currentTimeRemaining,
                            doesPlaySounds: optionsModel.options.completionFeedback == .sound
                        ) { error in
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
                        totalSeconds: timerModel.totalSecondsForCurrentMode,
                        actionPreview: resolvedLiveActivityPreview()
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
                showCompanionSheet = true
            } else {
                await Task.yield()
                showWelcomeSheet = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification), perform: { _ in
            allActions.actions.forEach { a in
                let isContained = selectActions.actions.contains { element in
                    if element.title == a.title {
                        return true
                    }
                    return false
                }

                if a.pinned && !isContained {
                    let newAction = BreakAction(title: a.title, description: a.description, categoryId: a.categoryId, duration: a.duration, pinned: true, completed: false, date: Date.now, linkurl: a.linkurl, frequency: a.frequency)
                    selectActions.actions.insert(newAction, at: 0)
                }
            }
        })
        .onChange(of: notificationManager.authorizationStatus) { newStatus in
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
            if isStarted {
                guard optionsModel.options.liveActivityEnabled else { return }
                liveActivityManager.startActivity(
                    isWorkTime: timerModel.isWorkTime,
                    timeRemaining: timerModel.currentTimeRemaining,
                    totalSeconds: timerModel.totalSecondsForCurrentMode,
                    actionPreview: resolvedLiveActivityPreview()
                )
            } else if !timerModel.isComplete, optionsModel.options.liveActivityEnabled {
                liveActivityManager.updateActivity(
                    isWorkTime: timerModel.isWorkTime,
                    isRunning: false,
                    timeRemaining: timerModel.currentTimeRemaining,
                    totalSeconds: timerModel.totalSecondsForCurrentMode,
                    actionPreview: resolvedLiveActivityPreview()
                )
            }
        }
        .onChange(of: timerModel.isComplete) { isComplete in
            if isComplete {
                liveActivityManager.showTimerFinishedThenEnd(
                    isWorkTime: timerModel.isWorkTime,
                    totalSeconds: timerModel.totalSecondsForCurrentMode,
                    actionPreview: resolvedLiveActivityPreview()
                )
            }
        }
        .onChange(of: optionsModel.options) { _ in
            applyLiveActivityForCurrentOptions()
        }
        .onChange(of: timerModel.isWorkTime) { _ in
            liveActivityManager.endActivity()
        }
        .onOpenURL { url in
            guard url.scheme == "timeforabreak", url.host == "voice" else { return }
            companionVoiceLog = true
        }
        .sheet(isPresented: $showDaySetupSheet, onDismiss: {
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
            showCompanionSheet = true
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
