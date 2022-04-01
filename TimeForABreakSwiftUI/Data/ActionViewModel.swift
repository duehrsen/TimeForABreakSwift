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
    
    func add(action: String) {
        print("in it with string \(action)")
        let newAction = BreakAction(title: action, desc: action, duration: 3, category: "regular")
        actions.append(newAction)
    }
    
}
