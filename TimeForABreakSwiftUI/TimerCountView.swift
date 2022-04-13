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
    @EnvironmentObject var notificationManager : NotificationManager
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme

    @State private var time = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var didAppear : Bool = false
    @State private var showingSheet : Bool = false
    @State private var showingCompleteSheet : Bool = false
    
    var defaultAction : BreakAction = BreakAction(title: "Get up!", desc: "Leave your chair", duration: 1, category: "relax")
    
    let cal = Calendar.current
    
    func convertSecondsToTime(timeinSeconds : Int) -> String {
        let minutes = timeinSeconds / 60
        let seconds = timeinSeconds % 60
        
        return String(format: "%02i:%02i", minutes,seconds)
    }
    
    fileprivate func switchTimer() {
        tm.started = false
        tm.isWorkTime.toggle()
        tm.currentTimeRemaining =  tm.isWorkTime ? tm.workTimeTotalSeconds : tm.breakTimeTotalSeconds
        tm.to = CGFloat(tm.currentTimeRemaining) / CGFloat(tm.isWorkTime ? tm.workTimeTotalSeconds : tm.breakTimeTotalSeconds)
    }
    
    var body: some View {
        
        let diameter : CGFloat = 225
        //let outofSize : CGFloat = 10
        let timerTextSize : CGFloat = 60
        let playIconSize : CGFloat = 40
        let bglineWidth : CGFloat = 12
        let tplineWidth : CGFloat = 4
        
        VStack(spacing: 25) {
            Button {
                tm.started.toggle()
            } label: {
                ZStack {
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke(Color.black.opacity(0.2),style: StrokeStyle(lineWidth: bglineWidth, lineCap: .round))
                        .frame(minWidth: CGFloat(diameter * 0.7), idealWidth: diameter, maxWidth: diameter*1.2, minHeight: CGFloat(diameter * 0.7), idealHeight: diameter, maxHeight:diameter*1.2 )
                    
                    Circle()
                        .trim(from: 0, to: tm.to)
                        .stroke(Color(UIColor.systemBlue).opacity(0.8),style: StrokeStyle(lineWidth: tplineWidth, lineCap: .butt))
                        .frame(minWidth: CGFloat(diameter * 0.7), idealWidth: diameter, maxWidth: diameter*1.2, minHeight: CGFloat(diameter * 0.7), idealHeight: diameter, maxHeight:diameter*1.2 )
                        .rotationEffect(.init(degrees: -90))
                    VStack {
                        Label("", systemImage: tm.isWorkTime ? "brain" : "cup.and.saucer.fill")
                            .font(.system(size: diameter/3))
                            .opacity(0.8)
                            .foregroundColor(tm.isWorkTime ? Color.pink : Color.blue)
                        Text("\(convertSecondsToTime(timeinSeconds:tm.currentTimeRemaining))")
                            .font(.system(size: timerTextSize))
                            .fontWeight(.bold)
                        Label("", systemImage: tm.started ? "pause.fill" : "play.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: playIconSize))
                    }                    
                }
            }
            
            VStack() {
                HStack(spacing: 10) {
                Button(action: {
                    tm.resetTimer()
                }) {
                    HStack(spacing: 15){
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.white)
                        Text("Restart")
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                    .padding()
                    //.frame(width: UIScreen.main.bounds.width - 40)
                    .background(Color.blue)
                    .clipShape(Capsule())
                    .shadow(radius: 5)
                    
                }
                
                Button(action: {
                    switchTimer()
                }) {
                    HStack(spacing: 15){
                        Image(systemName: tm.isWorkTime ? "cup.and.saucer.fill": "brain")
                            .foregroundColor(.white)
                        Text("Switch")
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                    .padding()
                    //.frame(width: UIScreen.main.bounds.width - 40)
                    .background(Color.orange)
                    .clipShape(Capsule())
                    .shadow(radius: 5)
                }
            }
        }
            
            Button(action: {
                showingSheet.toggle()
            }) {
                HStack(spacing: 15){
                    Image(systemName: "eyes.inverse")
                        .foregroundColor(.white)
                    Text("Show Actions")
                        .foregroundColor(.white)
                        .font(.caption)
                }
                .padding()
                //.frame(width: UIScreen.main.bounds.width - 40)
                .background(Color.green)
                .clipShape(Capsule())
                .shadow(radius: 5)
            }
        }
        .sheet(isPresented: $showingSheet, content: {
            SelectedActionsSheetView()
        })
        .sheet(isPresented: $showingCompleteSheet, content: {
            TimerCompletionView(isFinishedWork: !tm.isWorkTime )
        })
        .onReceive(self.time) { (_) in
            if tm.started && tm.currentTimeRemaining > 0 {
                tm.currentTimeRemaining -= 1
                tm.to = CGFloat(tm.currentTimeRemaining) / CGFloat(tm.isWorkTime ? tm.workTimeTotalSeconds : tm.breakTimeTotalSeconds)
            }
            
            else if tm.started && (scenePhase == .active) {
                tm.started = false
                showingCompleteSheet.toggle()
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
