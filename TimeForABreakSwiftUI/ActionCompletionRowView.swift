//
//  ActionCompletionRowView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-04.
//

import SwiftUI

struct ActionCompletionRowView: View {
    @EnvironmentObject private var vm : ActionViewModel
    @State private var isComplete: Bool = false
    let action: BreakAction
    
    var body: some View {
        HStack(spacing: 6) {
            Button {
                self.toggleCompletion()
            } label: {
                Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(isComplete ? Color.green : Color.brown)
            }
            Text(action.title)
                .frame(minWidth: 100, idealWidth: 120, maxWidth: 160, alignment: .leading)
                .font(.title2)
            Text("Up to " + action.duration.formatted() + " min")
                .frame(minWidth: 60, idealWidth: 100, maxWidth: 100, alignment: .trailing)
                .font(.subheadline)
                .padding()
        }
    }
    
    private func toggleCompletion() {
        isComplete.toggle()
        
    }
}

//struct ActionCompletionRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActionCompletionRowView(action: BreakAction)
//    }
//}
