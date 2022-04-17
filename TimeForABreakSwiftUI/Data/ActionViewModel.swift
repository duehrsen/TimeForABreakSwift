//
//  ActionViewModel.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-01.
//

import SwiftUI
import Alamofire

class ActionViewModel: ObservableObject {
    
    private var fileBase : String = "breakActions"
    
    var actions : [BreakAction] = [] {
        didSet {
            actions.sort { (lhs, rhs) -> Bool in
                if lhs.pinned && !rhs.pinned {
                    return true
                }
//                else if lhs.title < rhs.title {
//                    return true
//                }
                return false
            }
            objectWillChange.send()
        }
    }
    
    private func fileURL() throws -> URL {
        
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("\(fileBase).data")
        
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
        let defaultData = DataProvider.mockData()
        actions = defaultData
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
            print("Item doesn't need to be pin toggled")
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
            print("Random activity title: \(activityString)")
            if (activityString.count > 2)
            {
                let newAction = BreakAction(title: activityString, desc: "", duration: 60, category: "external")
                self.actions.insert(newAction, at: 0)
            }
        }
    
    }
}
