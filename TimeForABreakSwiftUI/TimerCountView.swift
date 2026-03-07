//
//  TimerCountView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-30.
//

import SwiftUI

struct TimerCountView: View {
    @EnvironmentObject var timerModel: TimerModel
    @EnvironmentObject var selectActions: SelectedActionsViewModel
    @Environment(\.colorScheme) var colorScheme

    @State private var didAppear: Bool = false
    @State private var showingSheet: Bool = false
    @State private var showingCompleteSheet: Bool = false

    var defaultAction: BreakAction = BreakAction(title: "Get up!", description: "Leave your chair", categoryId: "mental", duration: 1)

    let cal = Calendar.current

    var body: some View {

        let diameter: CGFloat = 225
        let timerTextSize: CGFloat = 60
        let playIconSize: CGFloat = 40
        let bglineWidth: CGFloat = 12
        let tplineWidth: CGFloat = 4

        VStack(spacing: 25) {
            Button {
                timerModel.toggle()
            } label: {
                ZStack {
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke(Color.orange.opacity(0.3), style: StrokeStyle(lineWidth: bglineWidth, lineCap: .round))
                        .frame(minWidth: CGFloat(diameter * 0.7), idealWidth: diameter, maxWidth: diameter * 1.2, minHeight: CGFloat(diameter * 0.7), idealHeight: diameter, maxHeight: diameter * 1.2)

                    Circle()
                        .trim(from: 0, to: timerModel.progress)
                        .stroke(Color(UIColor.systemBlue).opacity(0.8), style: StrokeStyle(lineWidth: tplineWidth, lineCap: .butt))
                        .frame(minWidth: CGFloat(diameter * 0.7), idealWidth: diameter, maxWidth: diameter * 1.2, minHeight: CGFloat(diameter * 0.7), idealHeight: diameter, maxHeight: diameter * 1.2)
                        .rotationEffect(.init(degrees: -90))
                    VStack {
                        Label("", systemImage: timerModel.isWorkTime ? "brain" : "cup.and.saucer.fill")
                            .font(.system(size: diameter / 3))
                            .opacity(0.8)
                            .foregroundColor(timerModel.isWorkTime ? Color.pink : Color.blue)
                        Text(timerModel.formattedTime)
                            .font(.system(size: timerTextSize))
                            .fontWeight(.bold)
                        Label("", systemImage: timerModel.started ? "pause.fill" : "play.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: playIconSize))
                    }
                }
            }

            VStack() {
                HStack(spacing: 10) {
                Button(action: {
                    timerModel.reset()
                }) {
                    HStack(spacing: 15) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.white)
                        Text("Restart")
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                    .padding()
                    .background(Color.blue)
                    .clipShape(Capsule())
                    .shadow(radius: 5)
                }

                Button(action: {
                    timerModel.switchMode()
                }) {
                    HStack(spacing: 15) {
                        Image(systemName: timerModel.isWorkTime ? "cup.and.saucer.fill" : "brain")
                            .foregroundColor(.white)
                        Text("Switch")
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                    .padding()
                    .background(Color.orange)
                    .clipShape(Capsule())
                    .shadow(radius: 5)
                }
            }
        }

            Button(action: {
                showingSheet.toggle()
            }) {
                HStack(spacing: 15) {
                    Image(systemName: "eyes.inverse")
                        .foregroundColor(.white)
                    Text("Show Today's Actions")
                        .foregroundColor(.white)
                        .font(.caption)
                }
                .padding()
                .background(Color.green)
                .clipShape(Capsule())
                .shadow(radius: 5)
            }
        }
        .sheet(isPresented: $showingSheet, content: {
            SelectedActionsSheetView()
        })
        .sheet(isPresented: $showingCompleteSheet, content: {
            TimerCompletionView(isFinishedWork: !timerModel.isWorkTime)
        })
        .onChange(of: timerModel.isComplete) { isComplete in
            if isComplete {
                showingCompleteSheet = true
                timerModel.acknowledgeCompletion()
            }
        }
        .onAppear {
            if !didAppear {
                timerModel.reset()
                didAppear = true
            }
        }
    }
}
