//
//  SelectedActionsViewModel.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-11.
//

import SwiftUI
import Alamofire

class SelectedActionsViewModel: ObservableObject {
    
    @Published var selectedActions : [BreakAction] = []
    
    init() {
        selectedActions = [BreakAction(title: "Get up", desc: "", duration: 3, category: "regular")]
    }
    
    private var fileBase : String = "selectedActions"
    
    let cal = Calendar.current
    
    @Published var actions : [BreakAction] = []
    
    private func fileURL() throws -> URL {
        
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("\(fileBase).data")
        
    }
    
    func getTodaysActions() -> [BreakAction] {
        return selectedActions.filter{cal.isDateInToday($0.date ?? Date(timeInterval: -36000, since: Date())) && $0.completed}
    }
    
    func getYestActions() -> [BreakAction] {
        return selectedActions.filter{cal.isDateInYesterday($0.date ?? Date(timeInterval: -36000, since: Date())) && $0.completed}
    }
    
    func countedHistoryActions(actions: [BreakAction]) -> [BreakAction]
    {
        var countedActions : [BreakAction] = []
        var alreadyCountedTitles : [String] = []
        
        actions.forEach { action in
            
            if alreadyCountedTitles.contains(action.title) {
                print("Duplicate \(action.title)")
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
    
    func save(actions: [BreakAction], completion: @escaping (Result<Int, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(actions)
                let outfile = try self.fileURL()
                try data.write(to: outfile)
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func load(completion: @escaping (Result<[BreakAction], Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileUrl = try self.fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileUrl) else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
                let aryActionBreaks = try JSONDecoder().decode([BreakAction].self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(aryActionBreaks))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            
        }
        
    }
    
    func saveToDisk() {
        self.save(actions: actions) { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func restoreDefaultsToDisk() {
        actions = []
        let defaultData = DataProvider.mockData()
        actions = defaultData
        self.save(actions: []) { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
            }
        }
        self.save(actions: defaultData) { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
            }
        }
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
