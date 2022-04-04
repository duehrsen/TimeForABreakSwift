//
//  TimerCountView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-30.
//

import SwiftUI

struct TimerCountView: View {
    @EnvironmentObject var timerModel : TimerModel
    @EnvironmentObject var selectActions : SelectedActionsViewModel
    @State var started = false
    @State var to : CGFloat = 1
    @State var time = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var didAppear : Bool = false
    var defaultAction : BreakAction = BreakAction(title: "Get up!", desc: "Leave your chair", duration: 1, category: "relax")
    @State var isWorkTime : Bool = true
    
    
    func convertSecondsToTime(timeinSeconds : Int) -> String {
        let minutes = timeinSeconds / 60
        let seconds = timeinSeconds % 60
        
        return String(format: "%02i:%02i", minutes,seconds)
    }
    
    var body: some View {
        
        let diameter : CGFloat = 200
        let outofSize : CGFloat = 20
        let timerTextSize : CGFloat = 40
        let lineWidth : CGFloat = 30
        
        VStack(spacing: 60) {
            Spacer()
            Text(isWorkTime ? "Workin' time left" : "Chillin' Time Left")
                .font(.largeTitle)
            ZStack {
                Circle()
                    .trim(from: 0, to: 1)
                    .stroke(Color.black.opacity(0.09),style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .frame(width: diameter, height: diameter)
                Circle()
                    .trim(from: 0, to: self.to)
                    .stroke(Color.blue,style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .frame(width: diameter, height: diameter)
                    .rotationEffect(.init(degrees: -90))
                VStack {
                    Text("\(convertSecondsToTime(timeinSeconds:timerModel.currentTimeRemaining))")
                        .font(.system(size: timerTextSize))
                        .fontWeight(.bold)
                    Text("out of \(convertSecondsToTime(timeinSeconds: isWorkTime ? timerModel.workTimeTotalSeconds : timerModel.breakTimeTotalSeconds))")
                        .font(.system(size: outofSize))
                }
                
            }
            
            HStack (spacing: 20) {
                Button(action: {
                    self.started.toggle()
                    
                }) {
                    HStack(spacing: 15){
                        Image(systemName: self.started ? "pause.fill" : "play.fill")
                            .foregroundColor(.white)
                        Text(self.started ? "Pause" : "Play")
                            .foregroundColor(.white)
                    }
                    .padding(.vertical)
                    .frame(width: (UIScreen.main.bounds.width / 2) - 55)
                    .background(Color.blue)
                    .clipShape(Capsule())
                    .shadow(radius: 5)
                }
                
                Button(action: {
                    timerModel.currentTimeRemaining = isWorkTime ? timerModel.workTimeTotalSeconds : timerModel.breakTimeTotalSeconds
                    self.started = true
                    self.to = 0
                    
                }) {
                    HStack(spacing: 15){
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                        Text("Restart")
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical)
                    .frame(width: (UIScreen.main.bounds.width / 2) - 55)
                    .background(
                        Capsule()
                            .stroke(Color.blue, lineWidth: 2)
                    )
                    .shadow(radius: 5)
                    
                }
                
            }
            
            List {
                Section("Your actions for today") {
                    
                }
                ForEach(selectActions.selectedActions , id: \.id) {
                    item in
                    HStack {
                        Text(item.title)
                            .frame(minWidth: 100, idealWidth: 120, maxWidth: 160, alignment: .leading)
                            .font(.title2)
                        Text("Up to " + item.duration.formatted() + " min")
                            .frame(minWidth: 60, idealWidth: 100, maxWidth: 100, alignment: .trailing)
                            .font(.subheadline)
                            .padding()
                    }
                    
                }
                .onDelete(perform: selectActions.deleteAction)
                .onMove(perform: selectActions.move)
            }
            
            
        }
        .onReceive(self.time) { (_) in
            print("Tick")
            if self.started && timerModel.currentTimeRemaining > 0 {
                timerModel.currentTimeRemaining -= 1
                self.to = CGFloat(timerModel.currentTimeRemaining) / CGFloat(timerModel.workTimeTotalSeconds)
            } else if self.started {
                self.started.toggle()
                isWorkTime.toggle()
                timerModel.currentTimeRemaining =  isWorkTime ? timerModel.workTimeTotalSeconds : timerModel.breakTimeTotalSeconds
                self.to = CGFloat(timerModel.currentTimeRemaining) / CGFloat(timerModel.workTimeTotalSeconds)
            }
            
        }
        .onAppear {
            timerModel.currentTimeRemaining = timerModel.workTimeTotalSeconds
            
        }
        
    }
}

struct TimerCountView_Previews: PreviewProvider {
    static var previews: some View {
        TimerCountView()
    }
}
