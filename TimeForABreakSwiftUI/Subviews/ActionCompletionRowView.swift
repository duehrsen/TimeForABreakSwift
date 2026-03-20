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
                .font(.body)
                .badge(badgeText)
        }
    }
    
    private func toggleCompletion() {
        isComplete.toggle()
        vm.update(id: action.id, newtitle: action.title, duration: action.duration, completed: isComplete)

        // When marking complete, record a completion entry so repeat usage and
        // quantities can be aggregated in Summary and badges.
        if isComplete {
            let quantity: Int?
            if action.isQuantifiable {
                // Use explicit default quantity when provided, otherwise fall back to 1
                quantity = action.defaultQuantity ?? 1
            } else {
                quantity = nil
            }
            vm.addCompletion(actionId: action.id, quantity: quantity, source: .manual)
        }
    }

    private var badgeText: String {
        let stats = vm.todaysStats(for: action)

        if let total = stats.totalQuantity, action.isQuantifiable, let unit = action.displayUnit(forQuantity: total) {
            return "\(total) \(unit)"
        }

        if stats.count > 0 {
            return "×\(stats.count)"
        }

        // Fallback: keep the old duration-based hint
        return action.duration < 30 ? "\(action.duration) min" : "a while"
    }
}
