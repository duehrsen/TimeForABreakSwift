//
//  SelectedActionsViewModel.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-11.
//

import Combine
import SwiftUI
import Alamofire

class SelectedActionsViewModel: ObservableObject {

    private let persistence = PersistenceManager<[BreakAction]>(fileName: "selectedActions", defaultValue: [])

    let cal = Calendar.current

    @Published var actions: [BreakAction] = []
    
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
                    let newAction = BreakAction(title: action.title, desc: action.desc, duration: action.duration, category: action.category, completed: action.completed, date: action.date, frequency: matchingTitles.count)
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
        let newItem = BreakAction(id: id, title: newtitle, desc: "", duration: duration, category: "regular", completed: completed, date: Date())
        if let thisInd = actions.firstIndex(where: {$0.id == id} )
        {
            actions.replaceSubrange(thisInd...thisInd, with: repeatElement(newItem, count: 1))
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
        let newAction = BreakAction(title: action, desc: action, duration: duration, category: "regular", date: date)
        actions.insert(newAction, at: 0)
        saveToDisk()
    }
    
}
