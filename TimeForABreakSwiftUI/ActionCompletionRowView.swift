//
//  ActionCompletionRowView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-04.
//

import SwiftUI

struct ActionCompletionRowView: View {
    @EnvironmentObject private var vm : SelectedActionsViewModel
    @State private var isComplete: Bool = false
    let action: BreakAction
    let editable : Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Button {
                if editable {
                    self.toggleCompletion()
                }
            } label: {
                Image(systemName: action.completed ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(action.completed ? Color.green : Color.brown)
                    .padding(.trailing)
            }
            Text(action.title)
                .font(.title2)
                .badge(action.duration < 30 ? action.duration.formatted() + " min" : "a while")
        }
    }
    
    private func toggleCompletion() {
        isComplete.toggle()
        vm.update(id: action.id, newtitle: action.title, duration: action.duration, completed: isComplete)
    }
}
