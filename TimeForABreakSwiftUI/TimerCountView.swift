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
        
        let diameter : CGFloat = 280
        //let outofSize : CGFloat = 10
        let timerTextSize : CGFloat = 60
        let playIconSize : CGFloat = 80
        let bglineWidth : CGFloat = 15
        let tplineWidth : CGFloat = 8
        
        VStack(spacing: 25) {
            Spacer()
            Text(tm.isWorkTime ? "Workin' time left" : "Chillin' Time Left").font(.largeTitle)
            Button {
                tm.started.toggle()
            } label: {
                ZStack {
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke(Color.black.opacity(0.1),style: StrokeStyle(lineWidth: bglineWidth, lineCap: .round))
                        .frame(minWidth: CGFloat(diameter * 0.7), idealWidth: diameter, maxWidth: diameter*1.2, minHeight: CGFloat(diameter * 0.7), idealHeight: diameter, maxHeight:diameter*1.2 )
                    Circle()
                        .trim(from: 0, to: tm.to)
                        .stroke(Color.blue.opacity(0.7),style: StrokeStyle(lineWidth: tplineWidth, lineCap: .butt))
                        .frame(width: CGFloat(diameter * 0.8), height: CGFloat(diameter * 0.8))
                        .rotationEffect(.init(degrees: -90))
                    VStack {
                        Text("\(convertSecondsToTime(timeinSeconds:tm.currentTimeRemaining))")
                            .font(.system(size: timerTextSize))
                            .fontWeight(.bold)
                        Label("", systemImage: tm.started ? "pause.fill" : "play.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: playIconSize))
                    }
                    
                }
            }

            
            HStack (spacing: 20) {
                
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
                ForEach(selectActions.actions , id: \.id) {
                    item in
                        ActionCompletionRowView(action: item)
                    
                }
                .onDelete(perform: selectActions.deleteAction)
                .onMove(perform: selectActions.move)
            }.listStyle(.plain)
            
            
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
