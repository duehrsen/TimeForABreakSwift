//
//  TimeRemainingSubView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-16.
//

import SwiftUI

struct TimeRemainingSubView: View {
    @EnvironmentObject var tM : TimerModel
    
    var body: some View {
        ZStack {
            HStack {
                Image(systemName: tM.isWorkTime ? "brain" : "cup.and.saucer.fill")
                    .foregroundColor(tM.isWorkTime ? Color.pink : Color.blue)
                Text(tM.formattedTime)
                    .font(.system(size: 24))
            }
        }
    }
}

