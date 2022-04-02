//
//  ActionViewModel.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-01.
//

import SwiftUI

class ActionViewModel: ObservableObject {
    @Published var actions : [BreakAction] = []
    
    func getData() {
        actions = DataProvider.mockData()
    }
    
    func deleteAction(index: IndexSet) {
        actions.remove(atOffsets: index)
    }
    
    func move(index: IndexSet, dest: Int) {
        actions.move(fromOffsets: index, toOffset: dest)
    }
    
    func add(action: String = "", duration: Int = 5) {
        print("Adding default action with action title \(action) and duration \(duration)")
        let newAction = BreakAction(title: action, desc: action, duration: duration, category: "regular")
        actions.insert(newAction, at: 0)
    }
    
}

class SelectedActionsViewModel: ObservableObject {
    
    @Published var selectedActions : [BreakAction] = []
    
    init() {
        selectedActions = [BreakAction(title: "Get up", desc: "", duration: 3, category: "regular")]
    }
    
    func add(action: BreakAction) {
        selectedActions.insert(action, at: 0)
        print("Action added to active list. Count is \(selectedActions.count)")
    }
    
    func deleteAction(index: IndexSet) {
        selectedActions.remove(atOffsets: index)
    }
    
    func move(index: IndexSet, dest: Int) {
        selectedActions.move(fromOffsets: index, toOffset: dest)
    }
}