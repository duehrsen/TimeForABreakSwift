//
//  TimerCountView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-30.
//

import SwiftUI

struct TimerCountView: View {
    @EnvironmentObject var tm : TimerModel
    @EnvironmentObject var selectActions : SelectedActionsViewModel

    @State var time = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var didAppear : Bool = false
    var defaultAction : BreakAction = BreakAction(title: "Get up!", desc: "Leave your chair", duration: 1, category: "relax")

    
    func convertSecondsToTime(timeinSeconds : Int) -> String {
        let minutes = timeinSeconds / 60
        let seconds = timeinSeconds % 60
        
        return String(format: "%02i:%02i", minutes,seconds)
    }
    
    fileprivate func switchTimer() {
        tm.started.toggle()
        tm.isWorkTime.toggle()
        tm.currentTimeRemaining =  tm.isWorkTime ? tm.workTimeTotalSeconds : tm.breakTimeTotalSeconds
        tm.to = CGFloat(tm.currentTimeRemaining) / CGFloat(tm.isWorkTime ? tm.workTimeTotalSeconds : tm.breakTimeTotalSeconds)
    }
    
    var body: some View {
        
        let diameter : CGFloat = 200
        //let outofSize : CGFloat = 10
        let timerTextSize : CGFloat = 50
        let playIconSize : CGFloat = 50
        let lineWidth : CGFloat = 30
        
        VStack(spacing: 60) {
            Spacer()
            Text(tm.isWorkTime ? "Workin' time left" : "Chillin' Time Left")
                .font(.largeTitle)
            Button {
                tm.started.toggle()
            } label: {
                ZStack {
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke(Color.black.opacity(0.09),style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                        .frame(width: diameter, height: diameter)
                    Circle()
                        .trim(from: 0, to: tm.to)
                        .stroke(Color.blue,style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                        .frame(width: diameter, height: diameter)
                        .rotationEffect(.init(degrees: -90))
                    VStack {
                        Text("\(convertSecondsToTime(timeinSeconds:tm.currentTimeRemaining))")
                            .font(.system(size: timerTextSize))
                            .fontWeight(.bold)
                        Label("", systemImage: tm.started ? "pause.fill" : "play.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: playIconSize))
                        //Text("out of \(convertSecondsToTime(timeinSeconds: tm.isWorkTime ? tm.workTimeTotalSeconds : tm.breakTimeTotalSeconds))").font(.system(size: outofSize))
                    }
                    
                }
            }

            
            HStack (spacing: 20) {
//                Button(action: {
//                    tm.started.toggle()
//
//                }) {
//                    HStack(spacing: 15){
//                        Image(systemName: tm.started ? "pause.fill" : "play.fill")
//                            .foregroundColor(.white)
//                        Text(tm.started ? "Pause" : "Play")
//                            .foregroundColor(.white)
//                    }
//                    .padding(.vertical)
//                    .frame(width: (UIScreen.main.bounds.width / 3) - 20)
//                    .background(Color.blue)
//                    .clipShape(Capsule())
//                    .shadow(radius: 5)
//                }
                
                Button(action: {
                    tm.currentTimeRemaining = tm.isWorkTime ? tm.workTimeTotalSeconds : tm.breakTimeTotalSeconds
                    tm.started = true
                    tm.to = 0
                    
                }) {
                    HStack(spacing: 15){
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.white)
                        Text("Restart")
                            .foregroundColor(.white)
                    }
                    .padding(.vertical)
                    .frame(width: (UIScreen.main.bounds.width / 2) - 55)
                    .background(Color.blue)
                    .clipShape(Capsule())
                    .shadow(radius: 5)
                    
                }
                
                Button(action: {
                    switchTimer()                    
                }) {
                    HStack(spacing: 15){
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.white)
                        Text("To " + (tm.isWorkTime ? "Break" : "Work"))
                            .foregroundColor(.white)
                    }
                    .padding(.vertical)
                    .frame(width: (UIScreen.main.bounds.width / 2) - 55)
                    .background(Color.green)
                    .clipShape(Capsule())
                    .shadow(radius: 5)
                    
                }
                
            }
            
            List {
                Section("Your actions for today") {
                    
                }
                ForEach(selectActions.selectedActions , id: \.id) {
                    item in
                        ActionCompletionRowView(action: item)
                    
                }
                .onDelete(perform: selectActions.deleteAction)
                .onMove(perform: selectActions.move)
            }
            
            
        }
        .onReceive(self.time) { (_) in
            if tm.started && tm.currentTimeRemaining > 0 {
                tm.currentTimeRemaining -= 1
                tm.to = CGFloat(tm.currentTimeRemaining) / CGFloat(tm.isWorkTime ? tm.workTimeTotalSeconds : tm.breakTimeTotalSeconds)
            } else if tm.started {
                switchTimer()
            }
            
        }
        .onAppear {
            if !didAppear {
                tm.currentTimeRemaining = tm.workTimeTotalSeconds
                didAppear = true
            }
            
        }
        
    }
}

struct TimerCountView_Previews: PreviewProvider {
    static var previews: some View {
        TimerCountView()
    }
}
