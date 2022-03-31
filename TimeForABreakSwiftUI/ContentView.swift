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
    @EnvironmentObject var timerModel: TimerModel
    var workMinutes : Int
    var breakMinutes : Int
    
    var body: some View {
        VStack {
            Text("Work time")
                .font(.title2)
            Stepper("\(workMinutes) minutes", value: $timerModel.workTimeTotalSeconds, in: 2...4000, step: 60) {_ in

            }
            .frame(width: 200)
            
            Text("Break time")
                .font(.title2)
            Stepper("\(breakMinutes) minutes", value: $timerModel.breakTimeTotalSeconds, in: 0...1000, step: 60) {_ in
                
            }
            .frame(width: 200)
//            Button(action: {
//                let workSec = workMinutes*60
//                let breakSec = breakMinutes*60
//                if (workSec != timerModel.workTimeTotalSeconds
//                    || breakSec != timerModel.breakTimeTotalSeconds) {
//                    timerModel.workTimeTotalSeconds = workSec
//                    timerModel.currentTimeRemaining = workSec
//                    timerModel.breakTimeTotalSeconds = breakSec
//                }
//            }) {
//                HStack(spacing: 15){
//                    Text("Save")
//                        .foregroundColor(.white)
//                }
//                .padding(.vertical)
//                .frame(width: (UIScreen.main.bounds.width / 2))
//                .background(Color.purple)
//                .clipShape(Capsule())
//                .shadow(radius: 5)
//            }
            //Slider(value: timer.breakTimeTotalSeconds, in: 0...timer.breakTimeTotalSeconds, step: 60)
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
                NavigationLink(destination: TimerCountView()) {
                    Text("START")
                }
                .buttonStyle(StandardButton())
                NavigationLink(destination: ActionListView()) {
                    Text("ACTIONS")
                }
                .buttonStyle(StandardButton())
                NavigationLink(destination: OptionsView(workMinutes: timerModel.workTimeTotalSeconds/60, breakMinutes: timerModel.breakTimeTotalSeconds/60)) {
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
