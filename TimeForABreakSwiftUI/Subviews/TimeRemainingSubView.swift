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
            Text(timerModel.formattedTime)
                .font(.system(size: 18))
                .monospacedDigit()
        }
        .frame(width: Self.toolbarTimerWidth, alignment: .center)
    }
}
