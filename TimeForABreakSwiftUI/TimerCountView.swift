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
    @EnvironmentObject var optionsModel: OptionsModel
    @Environment(\.colorScheme) var colorScheme

    @State private var didAppear: Bool = false
    @State private var showingListSheet: Bool = false
    @State private var showingVoiceSheet: Bool = false
    @State private var showingCompleteSheet: Bool = false

    @State private var previousCompletedCount: Int = 0
    @State private var segmentRingInitialized: Bool = false
    @State private var animatingSegmentIndex: Int? = nil
    @State private var segmentAnimationPhase: SegmentAnimationPhase = .preHighlight

    var defaultAction: BreakAction = BreakAction(title: "Get up!", description: "Leave your chair", categoryId: "mental", duration: 1)

    let cal = Calendar.current

    private enum Layout {
        static let timerDiameter: CGFloat = 225
        static let timerBackgroundLineWidth: CGFloat = 12
        static let timerProgressLineWidth: CGFloat = 4
        static let timerVerticalSpacing: CGFloat = 25
        static let segmentRingGap: CGFloat = 20
        static let segmentRingThickness: CGFloat = 13
        static let buttonHorizontalSpacing: CGFloat = 10
        static let loggingButtonsSpacing: CGFloat = 16
        static let timerTextSize: CGFloat = 60
        static let playIconSize: CGFloat = 40
    }

    private enum ActionRingLimits {
        static let minSegments = 6
        static let maxSegments = 10
    }

    private enum SegmentAnimationTiming {
        static let preHighlight: TimeInterval = 0.10
        static let lift: TimeInterval = 0.15
        static let fill: TimeInterval = 0.12
        static let snap: TimeInterval = 0.22
        static let settle: TimeInterval = 0.14
    }

    private var todayActions: [BreakAction] {
        selectActions.actions.filter { cal.isDateInToday($0.date ?? .distantPast) || $0.pinned }
    }

    private var segmentCount: Int {
        let count = todayActions.count
        guard count >= ActionRingLimits.minSegments else { return 0 }
        return min(count, ActionRingLimits.maxSegments)
    }

    private var completedCount: Int {
        guard segmentCount > 0 else { return 0 }
        let slice = Array(todayActions.prefix(segmentCount))
        return slice.filter(\.completed).count
    }

    /// Signature that changes when any of today’s actions’ completion state changes (for onChange).
    private var completionStateSignature: String {
        todayActions.prefix(segmentCount).map { "\($0.id)-\($0.completed)" }.joined(separator: "|")
    }

    private var ringRadius: CGFloat {
        let diameter = Layout.timerDiameter
        let bglineWidth = Layout.timerBackgroundLineWidth
        let gap = Layout.segmentRingGap
        let ringThickness = Layout.segmentRingThickness
        return diameter / 2 + bglineWidth + gap + ringThickness / 2
    }

    private func runSegmentCompletionAnimation(for index: Int) {
        guard segmentCount > 0 else { return }
        let reduceMotion = UIAccessibility.isReduceMotionEnabled
        animatingSegmentIndex = index
        segmentAnimationPhase = .preHighlight

        if reduceMotion {
            segmentAnimationPhase = .fill
            DispatchQueue.main.asyncAfter(deadline: .now() + SegmentAnimationTiming.fill) {
                segmentAnimationPhase = .settle
                DispatchQueue.main.asyncAfter(deadline: .now() + SegmentAnimationTiming.settle) {
                    animatingSegmentIndex = nil
                    previousCompletedCount = completedCount
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + SegmentAnimationTiming.preHighlight) {
            segmentAnimationPhase = .lift
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + SegmentAnimationTiming.preHighlight + SegmentAnimationTiming.lift) {
            segmentAnimationPhase = .fill
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + SegmentAnimationTiming.preHighlight + SegmentAnimationTiming.lift + SegmentAnimationTiming.fill) {
            withAnimation(.spring(response: SegmentAnimationTiming.snap, dampingFraction: 0.75)) {
                segmentAnimationPhase = .snap
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + SegmentAnimationTiming.preHighlight + SegmentAnimationTiming.lift + SegmentAnimationTiming.fill + SegmentAnimationTiming.snap) {
            segmentAnimationPhase = .settle
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + SegmentAnimationTiming.preHighlight + SegmentAnimationTiming.lift + SegmentAnimationTiming.fill + SegmentAnimationTiming.snap + SegmentAnimationTiming.settle) {
            animatingSegmentIndex = nil
            previousCompletedCount = completedCount
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    var body: some View {

        let diameter = Layout.timerDiameter
        let timerTextSize = Layout.timerTextSize
        let playIconSize = Layout.playIconSize
        let bglineWidth = Layout.timerBackgroundLineWidth
        let tplineWidth = Layout.timerProgressLineWidth
        let ringThickness = Layout.segmentRingThickness
        let ringSize: CGFloat = segmentCount > 0 ? (ringRadius + ringThickness) * 2 : 0

        VStack(spacing: Layout.timerVerticalSpacing) {
            Button {
                timerModel.toggle()
            } label: {
                ZStack {
                    if segmentCount > 0 {
                        ActionSegmentRingView(
                            segmentCount: segmentCount,
                            completedCount: completedCount,
                            animatingIndex: animatingSegmentIndex,
                            phase: segmentAnimationPhase,
                            ringRadius: ringRadius,
                            thickness: ringThickness
                        )
                        .frame(width: ringSize, height: ringSize)
                    }
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

            VStack {
                HStack(spacing: Layout.buttonHorizontalSpacing) {
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

            HStack(spacing: 16) {
                Button(action: {
                    showingVoiceSheet.toggle()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "mic.fill")
                            .foregroundColor(.white)
                        Text("Log by voice")
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .clipShape(Capsule())
                    .shadow(radius: 5)
                }

                Button(action: {
                    showingListSheet.toggle()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "checklist")
                            .foregroundColor(.white)
                        Text("Log from list")
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .clipShape(Capsule())
                    .shadow(radius: 5)
                }
            }
        }
        .sheet(isPresented: $showingListSheet, content: {
            SelectedActionsSheetView()
        })
        .sheet(isPresented: $showingVoiceSheet, content: {
            TimerVoiceLogSheetView()
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
            if !segmentRingInitialized && segmentCount > 0 {
                previousCompletedCount = completedCount
                segmentRingInitialized = true
            }
        }
        .onChange(of: completionStateSignature) { _ in
            let count = completedCount
            if segmentRingInitialized && segmentCount > 0 && count > previousCompletedCount {
                let targetIndex = min(previousCompletedCount, segmentCount - 1)
                runSegmentCompletionAnimation(for: targetIndex)
            }
        }
    }
}
