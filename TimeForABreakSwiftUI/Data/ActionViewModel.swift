//
//  ActionViewModel.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-01.
//

import Combine
import SwiftUI

/// Backing store for the master catalog of all available break actions.
/// Handles CRUD, persistence, and persistence to disk.
class ActionViewModel: ObservableObject {

    private let persistence = PersistenceManager<[BreakAction]>(fileName: "breakActions", defaultValue: [])

    var actions: [BreakAction] = [] {
        didSet {
            actions.sort { (lhs, rhs) -> Bool in
                if lhs.pinned && !rhs.pinned {
                    return true
                }
                return false
            }
            objectWillChange.send()
        }
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
    
    func update(
        id: UUID,
        newtitle: String,
        duration: Int,
        completed: Bool = false,
        isQuantifiable: Bool? = nil,
        unit: String? = nil,
        defaultQuantity: Int? = nil
    ) {
        var base = actions.first(where: { $0.id == id }) ?? BreakAction(
            id: id,
            title: newtitle,
            description: "",
            categoryId: "regular",
            duration: duration,
            completed: completed
        )

        base.title = newtitle
        base.duration = duration
        base.completed = completed

        if let isQuantifiable = isQuantifiable {
            base.isQuantifiable = isQuantifiable
        }
        if let unit = unit {
            base.unit = unit
        } else if isQuantifiable == false {
            base.unit = nil
        }
        if let defaultQuantity = defaultQuantity {
            base.defaultQuantity = defaultQuantity
        } else if isQuantifiable == false {
            base.defaultQuantity = nil
        }

        let newItem = base
        if let thisInd = actions.firstIndex(where: {$0.id == id} )
        {
            actions.replaceSubrange(thisInd...thisInd, with: repeatElement(newItem, count: 1))
        }
        saveToDisk()        
    }
    
    func pinToggle(action: BreakAction, toggleOn: Bool) -> Bool {
        var updateAction = action
        if (updateAction.pinned == toggleOn) {
            return false
        }
        updateAction.pinned = toggleOn
        if let thisInd = actions.firstIndex(where: {$0.id == updateAction.id} )
        {
            actions.replaceSubrange(thisInd...thisInd, with: repeatElement(updateAction, count: 1))
        }
        saveToDisk()
        return true
    }
    
    func deleteById(id: UUID) {
        if let thisInd = actions.firstIndex(where: {$0.id == id} )
        {
            actions.remove(at: thisInd)
        }
        saveToDisk()
    }
    
    func add(
        action: String = "",
        duration: Int = 5,
        isQuantifiable: Bool = false,
        unit: String? = nil,
        defaultQuantity: Int? = nil
    ) {
        let newAction = BreakAction(
            title: action,
            description: action,
            categoryId: "regular",
            duration: duration,
            isQuantifiable: isQuantifiable,
            unit: unit,
            defaultQuantity: defaultQuantity
        )
        actions.insert(newAction, at: 0)
        saveToDisk()
    }
}
