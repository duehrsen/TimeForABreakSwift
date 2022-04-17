//
//  TimerCompletionView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-12.
//

import SwiftUI
import AVFoundation

struct TimerCompletionView: View {
    
    @EnvironmentObject var selectActions : SelectedActionsViewModel
    @EnvironmentObject var os : OptionsModel
    
    @State var player : AVAudioPlayer?
    
    var isFinishedWork : Bool
    let cal = Calendar.current
    
    @EnvironmentObject var tm : TimerModel
    
    fileprivate func playSuccessSound() {
        let path = Bundle.main.path(forResource: "hornorganmusichockey.m4a", ofType: nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            
            player?.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            Text(isFinishedWork ? "Time for a break!" : "Hope you are recharged!")
                .font(.title2)
                .lineLimit(4)
                .minimumScaleFactor(0.5)
                .foregroundColor(Color.blue)
                .frame(width: UIScreen.main.bounds.width - 20, alignment: .center)
            Image(systemName: isFinishedWork ? "hands.sparkles.fill" : "bolt.fill")
                .font(.system(size: 80))
                .foregroundColor(Color.yellow)
                .frame(width: UIScreen.main.bounds.width - 20, alignment: .center)
                .onAppear(perform: {
                    tm.isWorkTime.toggle()
                    tm.resetTimer()
                })
            if isFinishedWork {
                List {
                    Section("Some actions left to do" ) {
                    }
                    ForEach(
                        selectActions.actions.filter{
                            
                            ( cal.isDateInToday($0.date ?? Date(timeInterval: -36000, since: Date())) || $0.pinned) && $0.completed == false
                            
                        } , id: \.id) {
                            item in
                            SimpleActionRowView(action: item)
                        }
                }.listStyle(.plain)
                    .frame(width: UIScreen.main.bounds.width - 20, alignment: .center)
            } else {
                SelectedActionsSheetView(isFromCompletedSheet: true)
                    .frame(width: UIScreen.main.bounds.width - 20, alignment: .center)
            }
        }
        .onAppear(){
            if os.options.doesPlaySounds {
                playSuccessSound()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

