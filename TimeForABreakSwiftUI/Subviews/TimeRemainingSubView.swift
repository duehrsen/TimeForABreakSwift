//
//  TimeRemainingSubView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-16.
//

import SwiftUI

struct TimeRemainingSubView: View {
    @EnvironmentObject var timerModel: TimerModel

    /// Keeps toolbar width stable so the principal title does not drift when the timer or icon changes.
    private static let toolbarTimerWidth: CGFloat = 108

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: timerModel.isWorkTime ? "brain" : "cup.and.saucer.fill")
                .foregroundColor(timerModel.isWorkTime ? Color.pink : Color.blue)
                .frame(width: 28, alignment: .center)
                .accessibilityHidden(true)
            Text(timerModel.formattedTime)
                .font(.body)
                .fontWeight(.medium)
                .monospacedDigit()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(timerModel.isWorkTime ? "Work timer" : "Break timer")
        .accessibilityValue(timerModel.formattedTime)
        .frame(width: Self.toolbarTimerWidth, alignment: .center)
    }
}
