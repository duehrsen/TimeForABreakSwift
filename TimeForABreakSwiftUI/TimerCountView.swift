//
//  TimerCountView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-30.
//

import SwiftUI

struct TimerCountView: View {
    @ObservedObject var timerModel : TimerModel
    @State var started = false
    @State var to : CGFloat = 1
    @State var time = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
      
    func convertSecondsToTime(timeinSeconds : Int) -> String {
        let minutes = timeinSeconds / 60
        let seconds = timeinSeconds % 60
        
        return String(format: "%02i:%02i", minutes,seconds)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 60) {
                ZStack {
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke(Color.black.opacity(0.09),style: StrokeStyle(lineWidth: 35, lineCap: .round))
                        .frame(width: 280, height: 280)
                    Circle()
                        .trim(from: 0, to: self.to)
                        .stroke(Color.purple,style: StrokeStyle(lineWidth: 35, lineCap: .round))
                        .frame(width: 280, height: 280)
                        .rotationEffect(.init(degrees: -90))
                    VStack {
                        Text("\(convertSecondsToTime(timeinSeconds:timerModel.currentTimeRemaining))")
                            .font(.system(size: 65))
                            .fontWeight(.bold)
                        Text("out of \(convertSecondsToTime(timeinSeconds:timerModel.workTimeTotalSeconds))")
                            .font(.title)
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
                        .background(Color.purple)
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                    }
                    
                    Button(action: {
                        timerModel.currentTimeRemaining = timerModel.workTimeTotalSeconds
                        self.started = true
                        self.to = 0
                        
                    }) {
                        HStack(spacing: 15){
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.purple)
                            Text("Restart")
                                .foregroundColor(.purple)
                        }
                        .padding(.vertical)
                        .frame(width: (UIScreen.main.bounds.width / 2) - 55)
                        .background(
                            Capsule()
                                .stroke(Color.purple, lineWidth: 2)
                            )
                        .shadow(radius: 5)

                    }
                    
                }
            }
            .onReceive(self.time) { (_) in
                print("Tick")
                if self.started && timerModel.currentTimeRemaining > 0 {
                    timerModel.currentTimeRemaining -= 1
                    self.to = CGFloat(timerModel.currentTimeRemaining) / CGFloat(timerModel.workTimeTotalSeconds)
                }
                
            }
        }
        .onAppear {
            timerModel.currentTimeRemaining = timerModel.workTimeTotalSeconds
        }
    }
}

//struct TimerCountView_Previews: PreviewProvider {
//    static var previews: some View {
//        TimerCountView()
//    }
//}
