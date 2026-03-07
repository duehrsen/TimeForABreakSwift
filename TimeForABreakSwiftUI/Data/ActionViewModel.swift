//
//  ActionViewModel.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-01.
//

import Combine
import SwiftUI
import Alamofire

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

    func save(actions: [BreakAction], completion: @escaping (Result<Int, Error>) -> Void) {
        persistence.save(data: actions, completion: completion)
    }

    func load(completion: @escaping (Result<[BreakAction], Error>) -> Void) {
        persistence.load(completion: completion)
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
    
    func update(id: UUID, newtitle: String, duration: Int, completed: Bool = false) {
        let newItem = BreakAction(id: id, title: newtitle, desc: "", duration: duration, category: "regular", completed: completed)
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
    
    func add(action: String = "", duration: Int = 5) {
        let newAction = BreakAction(title: action, desc: action, duration: duration, category: "regular")
        actions.insert(newAction, at: 0)
        saveToDisk()
    }
    
    func addActivityFromApi() {
        
        var activityString : String = ""
        
        AF.request("https://www.boredapi.com/api/activity?participants=1&type=relaxation").responseDecodable(of: BoredResponse.self) { response in
            guard let randomActivity = response.value else { return }
            activityString = randomActivity.activity
            if (activityString.count > 2)
            {
                let newAction = BreakAction(title: activityString, desc: "", duration: 60, category: "external")
                self.actions.insert(newAction, at: 0)
            }
        }
    
    }
}
