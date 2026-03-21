//
//  SelectedActionsViewModel.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-11.
//

import Combine
import SwiftUI

/// Manages the user's selected break actions for today and historical completions.
/// Responsible for building today's list, persisting it, and tracking completion history.
class SelectedActionsViewModel: ObservableObject {

    private let persistence = PersistenceManager<[BreakAction]>(fileName: "selectedActions", defaultValue: [])
    private let completionPersistence = PersistenceManager<[ActionCompletion]>(fileName: "actionCompletions", defaultValue: [])

    let cal = Calendar.current

    @Published var actions: [BreakAction] = []
    @Published var completions: [ActionCompletion] = []
    
    // MARK: - Helpers

    /// Returns actions that were scheduled for yesterday (by date).
    func yesterdayActions() -> [BreakAction] {
        actions.filter { cal.isDateInYesterday($0.date ?? .distantPast) }
    }

    /// Replace today's non-pinned actions with a new set built from the given templates.
    /// Pinned actions are preserved and left untouched.
    func setTodaysActions(from templates: [BreakAction]) {
        let today = cal.startOfDay(for: Date())

        // Remove any non-pinned actions dated today
        actions.removeAll { action in
            guard !action.pinned, let date = action.date else {
                return false
            }
            return cal.isDate(date, inSameDayAs: today)
        }

        // Add new actions for today (fresh IDs, reset completion/date)
        let newActions: [BreakAction] = templates.map { template in
            BreakAction(
                id: UUID(),
                title: template.title,
                description: template.description,
                spokenPrompt: template.spokenPrompt,
                categoryId: template.categoryId,
                duration: template.duration,
                isQuantifiable: template.isQuantifiable,
                unit: template.unit,
                defaultQuantity: template.defaultQuantity,
                triggerPhrases: template.triggerPhrases,
                suggestedPhrases: template.suggestedPhrases,
                timesPerDay: template.timesPerDay,
                preferredTimeRange: template.preferredTimeRange,
                isBuiltIn: template.isBuiltIn,
                pinned: template.pinned,
                completed: false,
                date: Date(),
                linkurl: template.linkurl,
                frequency: 1
            )
        }

        actions.append(contentsOf: newActions)
        saveToDisk()
    }
    
    func countedHistoryActions(actions: [BreakAction]) -> [BreakAction]
    {
        var countedActions : [BreakAction] = []
        var alreadyCountedTitles : [String] = []
        
        actions.forEach { action in
            
            if alreadyCountedTitles.contains(action.title) {
                // Skip duplicates
            } else {
                let matchingTitles = actions.filter { action.title == $0.title }
                if matchingTitles.count > 1 {
                    let newAction = BreakAction(title: action.title, description: action.description, categoryId: action.categoryId, duration: action.duration, completed: action.completed, date: action.date, frequency: matchingTitles.count)
                    countedActions.append(newAction)
                    alreadyCountedTitles.append(action.title)
                } else {
                    countedActions.append(action)
                }
            }         
            
        }
        
        return countedActions
    }

    // MARK: - Aggregated stats using completions

    struct ActionDailyStats: Identifiable {
        let id: UUID
        let action: BreakAction
        let count: Int
        let totalQuantity: Int?
    }

    /// Aggregated completion stats for a given calendar day, grouped by action.
    func dailyStats(for date: Date) -> [ActionDailyStats] {
        let dayStart = cal.startOfDay(for: date)

        let dayCompletions = completions.filter { completion in
            cal.isDate(completion.date, inSameDayAs: dayStart)
        }

        var grouped: [UUID: [ActionCompletion]] = [:]
        for completion in dayCompletions {
            grouped[completion.actionId, default: []].append(completion)
        }

        var stats: [ActionDailyStats] = []

        for (actionId, completionsForAction) in grouped {
            guard let action = actions.first(where: { $0.id == actionId }) else {
                continue
            }

            let count = completionsForAction.count
            let quantityValues = completionsForAction.compactMap { $0.quantity }
            let totalQuantity = quantityValues.isEmpty ? nil : quantityValues.reduce(0, +)

            stats.append(
                ActionDailyStats(
                    id: actionId,
                    action: action,
                    count: count,
                    totalQuantity: totalQuantity
                )
            )
        }

        // Sort by most completed first, then title
        return stats.sorted {
            if $0.count == $1.count {
                return $0.action.title < $1.action.title
            }
            return $0.count > $1.count
        }
    }

    /// Convenience helper for today's stats for a single action, used by row views.
    func todaysStats(for action: BreakAction) -> (count: Int, totalQuantity: Int?) {
        let today = cal.startOfDay(for: Date())
        let dayCompletions = completions.filter { completion in
            completion.actionId == action.id && cal.isDate(completion.date, inSameDayAs: today)
        }

        let count = dayCompletions.count
        let quantityValues = dayCompletions.compactMap { $0.quantity }
        let totalQuantity = quantityValues.isEmpty ? nil : quantityValues.reduce(0, +)

        return (count, totalQuantity)
    }
    
    func save(actions: [BreakAction]) async throws {
        try await persistence.save(data: actions)
    }

    func load() async throws -> [BreakAction] {
        try await persistence.load()
    }

    func saveToDisk() {
        persistence.saveToDisk(data: actions)
    }

    func restoreDefaultsToDisk() {
        actions = []
        let defaultData = DataProvider.mockData()
        actions = defaultData
        persistence.saveToDisk(data: defaultData)
    }
    
    
    func getData() {
        actions = DataProvider.mockData()
    }
    
    func emptyData() {
        actions = []
    }
    
    /// Removes today’s rows shown in `displayedInOrder` at `offsets` (List / ForEach order),
    /// and drops **all** `ActionCompletion` entries for those actions’ IDs so Summary and badges stay consistent.
    func deleteDisplayedTodayActions(at offsets: IndexSet, displayedInOrder ordered: [BreakAction]) {
        let idsToRemove = Set(offsets.map { ordered[$0].id })
        guard !idsToRemove.isEmpty else { return }

        completions.removeAll { idsToRemove.contains($0.actionId) }
        actions.removeAll { idsToRemove.contains($0.id) }

        saveCompletions()
        saveToDisk()
    }
    
    func move(index: IndexSet, dest: Int) {
        actions.move(fromOffsets: index, toOffset: dest)
        saveToDisk()
    }
    
    func update(id: UUID, newtitle: String, duration: Int, completed: Bool = false, date: Date = Date()) {
        guard let thisInd = actions.firstIndex(where: { $0.id == id }) else { return }
        let existing = actions[thisInd]
        var updated = existing
        updated.title = newtitle
        updated.duration = duration
        updated.completed = completed
        updated.date = date
        actions.replaceSubrange(thisInd...thisInd, with: [updated])
        objectWillChange.send()
        saveToDisk()
    }
    
    func pinToggle(action: BreakAction) {
        var updateAction = action
        updateAction.pinned = !action.pinned
        if let thisInd = actions.firstIndex(where: {$0.id == updateAction.id} )
        {
            actions.replaceSubrange(thisInd...thisInd, with: repeatElement(updateAction, count: 1))
        }
        saveToDisk()
    }
    
    func deleteById(id: UUID) {
        if let thisInd = actions.firstIndex(where: {$0.id == id} )
        {
            actions.remove(at: thisInd)
        }
        saveToDisk()
    }
    
    func add(action: String = "", duration: Int = 5, date: Date = Date()) {
        let newAction = BreakAction(title: action, description: action, categoryId: "chores", duration: duration, date: date)
        actions.insert(newAction, at: 0)
        saveToDisk()
    }

    /// Ensures there is a \"today\" instance of the given template action
    /// in the selected actions list, creating one if necessary.
    /// Used by voice logging so that any master action can be logged.
    func ensureTodayInstance(from template: BreakAction) -> BreakAction {
        let today = cal.startOfDay(for: Date())

        if let existing = actions.first(where: { candidate in
            candidate.title == template.title &&
            (candidate.pinned || (candidate.date.map { cal.isDate($0, inSameDayAs: today) } ?? false))
        }) {
            return existing
        }

        let newAction = BreakAction(
            id: UUID(),
            title: template.title,
            description: template.description,
            spokenPrompt: template.spokenPrompt,
            categoryId: template.categoryId,
            duration: template.duration,
            isQuantifiable: template.isQuantifiable,
            unit: template.unit,
            defaultQuantity: template.defaultQuantity,
            triggerPhrases: template.triggerPhrases,
            suggestedPhrases: template.suggestedPhrases,
            timesPerDay: template.timesPerDay,
            preferredTimeRange: template.preferredTimeRange,
            isBuiltIn: template.isBuiltIn,
            pinned: template.pinned,
            completed: false,
            date: Date(),
            linkurl: template.linkurl,
            frequency: 1
        )

        actions.insert(newAction, at: 0)
        saveToDisk()
        return newAction
    }

    // MARK: - Action Completions

    func loadCompletions() async throws -> [ActionCompletion] {
        try await completionPersistence.load()
    }

    func saveCompletions() {
        completionPersistence.saveToDisk(data: completions)
    }

    func addCompletion(actionId: UUID, quantity: Int? = nil, source: CompletionSource) {
        let completion = ActionCompletion(actionId: actionId, date: Date(), quantity: quantity, source: source)
        completions.append(completion)
        saveCompletions()
        UserDefaults.standard.set(true, forKey: "hasLoggedAnyAction")
    }
}
