//
//  ActionCompletionRowView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-04.
//

import SwiftUI

struct SimpleActionRowView: View {
    @EnvironmentObject private var vm : SelectedActionsViewModel
    @State private var isComplete: Bool = false
    let action: BreakAction
    
    var body: some View {
        HStack(spacing: 6) {
            Text(action.title)
                .font(.caption)
        }
    }
}
