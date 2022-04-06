//
//  ActionViewModel.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-01.
//

import SwiftUI

class ActionViewModel: ObservableObject {
    
    private var fileBase : String = "breakActions"
    
    @Published var actions : [BreakAction] = []
    
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
    
    func deleteById(id: UUID) {
        if let thisInd = actions.firstIndex(where: {$0.id == id} )
        {
            actions.remove(at: thisInd)
        }
        saveToDisk()
    }
    
    func add(action: String = "", duration: Int = 5) {
        print("Adding default action with action title \(action) and duration \(duration)")
        let newAction = BreakAction(title: action, desc: action, duration: duration, category: "regular")
        actions.insert(newAction, at: 0)
        saveToDisk()
    }
    
}

class SelectedActionsViewModel: ObservableObject {
    
    @Published var selectedActions : [BreakAction] = []
    
    init() {
        selectedActions = [BreakAction(title: "Get up", desc: "", duration: 3, category: "regular")]
    }
    
    private var fileBase : String = "selectedActions"
    
    @Published var actions : [BreakAction] = []
    
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
    
    func deleteById(id: UUID) {
        if let thisInd = actions.firstIndex(where: {$0.id == id} )
        {
            actions.remove(at: thisInd)
        }
        saveToDisk()
    }
    
    func add(action: String = "", duration: Int = 5, date: Date = Date()) {
        print("Adding default action with action title \(action) and duration \(duration)")
        let newAction = BreakAction(title: action, desc: action, duration: duration, category: "regular", date: date)
        actions.insert(newAction, at: 0)
        saveToDisk()
    }
    
}
