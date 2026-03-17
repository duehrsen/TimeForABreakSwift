//
//  SelectedActionsViewModel.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-11.
//

import Combine
import SwiftUI
import Alamofire

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
    
    func deleteAction(index: IndexSet) {
        actions.remove(atOffsets: index)
        saveToDisk()
    }
    
    func move(index: IndexSet, dest: Int) {
        actions.move(fromOffsets: index, toOffset: dest)
        saveToDisk()
    }
    
    func update(id: UUID, newtitle: String, duration: Int, completed: Bool = false, date: Date = Date()) {
        let newItem = BreakAction(id: id, title: newtitle, description: "", categoryId: "chores", duration: duration, completed: completed, date: Date())
        if let thisInd = actions.firstIndex(where: {$0.id == id} )
        {
            actions.replaceSubrange(thisInd...thisInd, with: repeatElement(newItem, count: 1))
            objectWillChange.send()
        }
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
    }
}
