//
//  TimeRemainingSubView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-16.
//

import SwiftUI

struct TimeRemainingSubView: View {
    @EnvironmentObject var timerModel : TimerModel
    
    var body: some View {
        ZStack {
            HStack {
                Image(systemName: timerModel.isWorkTime ? "brain" : "cup.and.saucer.fill")
                    .foregroundColor(timerModel.isWorkTime ? Color.pink : Color.blue)
                Text(timerModel.formattedTime)
                    .font(.system(size: 18))
            }
        }
    }
}

