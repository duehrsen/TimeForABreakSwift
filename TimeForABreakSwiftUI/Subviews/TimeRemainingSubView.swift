//
//  TimeRemainingSubView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-16.
//

import SwiftUI

struct TimeRemainingSubView: View {
    @EnvironmentObject var tM : TimerModel
    
    func convertSecondsToTime(timeinSeconds : Int) -> String {
        let minutes = timeinSeconds / 60
        let seconds = timeinSeconds % 60
        
        return String(format: "%02i:%02i", minutes,seconds)
    }
    
    var body: some View {
        ZStack {
            HStack {
                Image(systemName: tM.isWorkTime ? "brain" : "cup.and.saucer.fill")
                    .foregroundColor(tM.isWorkTime ? Color.pink : Color.blue)
                Text(convertSecondsToTime(timeinSeconds: tM.currentTimeRemaining))
                    .font(.system(size: 24))
            }
        }
    }
}

