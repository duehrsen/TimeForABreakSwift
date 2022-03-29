//
//  ContentView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-21.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var timerModel : TimerModel
    @State var headerLabelText : String = "Time To Work"
    @State var timerNumberLabel : String = "20:00"
    @State var timerButtonLabel : String = "START TIMER"
    @State var skipButtonLabel : String = "SKIP TO BREAK"
    
    var body: some View {
        VStack {
            Text(headerLabelText)
            Spacer()
            Text("\(self.timerModel.workTimeTotalSeconds)")
            Spacer()
            Button(timerButtonLabel) {}
                .buttonStyle(StandardButton())
            Button(skipButtonLabel) {}
                .buttonStyle(StandardButton())
        }
    }
    
    enum IntervalType : Int {
        case work = 600
        case notwork = 120
    }

    enum IntervalState {
        case inactive
        case active
        case paused
    }
    
    var binaryDescendingTime : Int = 0
    var totalTimeElapsed : Int = 0
    var timeElapsed : Int  = 0
    var interval : Int = 0
    
    var userActivityState = IntervalState.inactive
    var intervalType = IntervalType.work
    var maxTimeInInterval : Int = 1800
    var startDate = Date()
    
    
    var timer = Timer()
    
    func getTimeToDisplay(in maxTimeInInterval : Int) -> Int {
        abs(binaryDescendingTime * maxTimeInInterval - (timeElapsed + interval))
    }
       
    func convertSecondsToTime(timeinSeconds : Int) -> String {
        let minutes = timeinSeconds / 60
        let seconds = timeinSeconds % 60
        
        return String(format: "%02i:%02i", minutes,seconds)
    }
    
}



struct OptionsView: View {
    @EnvironmentObject var timer: TimerModel
    @State private var seconds : Int = 0
    
    var body: some View {
        VStack {
            Text("Options")
                .font(Font.title)
            Stepper("\(seconds) seconds", value: $seconds, in: 0...2000, step: 60) {_ in
                self.timer.workTimeTotalSeconds = seconds
            }
            //Slider(value: Float(timer.workTimeTotalSeconds), in: 0...timer.workTimeTotalSeconds, step: 60)
            Text("Work time in seconds is \(String(format: "%.0f",timer.workTimeTotalSeconds))")
            //Slider(value: timer.breakTimeTotalSeconds, in: 0...timer.breakTimeTotalSeconds, step: 60)
            Text("Break time in seconds is \(String(format: "%.0f",timer.breakTimeTotalSeconds))")
        }
    }
}


struct ContentView: View {
    
    @StateObject var timerModel = TimerModel()
    
    @State private var action: Int? = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Text("time \(timerModel.workTimeTotalSeconds)")
                NavigationLink(destination: TimerView()) {
                    Text("START")
                }
                .buttonStyle(StandardButton())
                NavigationLink(destination: ActionListView()) {
                    Text("ACTIONS")
                }
                .buttonStyle(StandardButton())
                NavigationLink(destination: OptionsView()) {
                    Text("OPTIONS")
                }
                .buttonStyle(StandardButton())
            }
        }
        .environmentObject(timerModel)

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
