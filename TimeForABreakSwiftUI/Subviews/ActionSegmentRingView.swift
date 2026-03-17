//
//  ActionSegmentRingView.swift
//  TimeForABreakSwiftUI
//
//  Outer ring of segments showing daily action completion. Segment 0 at bottom-left, clockwise.
//

import SwiftUI

// MARK: - Animation phase for one segment’s “snap-in” sequence

enum SegmentAnimationPhase {
    case preHighlight
    case lift
    case fill
    case snap
    case settle
}

// MARK: - Segment arc shape

private struct SegmentArc: Shape {
    var startAngleDeg: Double
    var arcAngleDeg: Double
    var ringRadius: CGFloat
    var thickness: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let startRad = startAngleDeg * .pi / 180
        let endRad = (startAngleDeg + arcAngleDeg) * .pi / 180
        var path = Path()
        path.addArc(center: center, radius: ringRadius, startAngle: .radians(startRad), endAngle: .radians(endRad), clockwise: false)
        return path
    }
}

// MARK: - Ring view

struct ActionSegmentRingView: View {
    var segmentCount: Int
    var completedCount: Int
    var animatingIndex: Int?
    var phase: SegmentAnimationPhase
    var ringRadius: CGFloat
    var thickness: CGFloat = 13
    var incompleteColor: Color = Color(.systemGray4).opacity(0.6)
    var completedColor: Color = Color.green

    private enum RingGeometry {
        static let fullCircleDeg: Double = 360.0
        static let visiblePortionPerSegment: Double = 0.8
    }

    private enum SegmentAnimationLayout {
        static let liftOffset: CGFloat = 6
        static let preHighlightScale: CGFloat = 1.04
        static let fillScale: CGFloat = 1.03
    }

    private var arcAngleDeg: Double {
        (RingGeometry.fullCircleDeg / Double(max(1, segmentCount))) * RingGeometry.visiblePortionPerSegment
    }

    private func startAngleDeg(for index: Int) -> Double {
        // Segment 0 at bottom-left (7:30), then clockwise
        return 225 + Double(index) * (RingGeometry.fullCircleDeg / Double(segmentCount))
    }

    private func isCompleted(_ index: Int) -> Bool {
        index < completedCount
    }

    private func isAnimating(_ index: Int) -> Bool {
        animatingIndex == index
    }

    private func scale(for index: Int) -> CGFloat {
        guard isAnimating(index) else { return 1.0 }
        switch phase {
        case .preHighlight, .lift: return SegmentAnimationLayout.preHighlightScale
        case .fill: return SegmentAnimationLayout.fillScale
        case .snap, .settle: return 1.0
        }
    }

    private func radialOffset(for index: Int) -> CGFloat {
        guard isAnimating(index) else { return 0 }
        switch phase {
        case .preHighlight: return 0
        case .lift, .fill: return SegmentAnimationLayout.liftOffset
        case .snap, .settle: return 0
        }
    }

    private func completedOpacity(for index: Int) -> Double {
        if isAnimating(index) {
            switch phase {
            case .preHighlight: return 0.8
            case .lift, .fill, .snap, .settle: return 1.0
            }
        }
        return isCompleted(index) ? 1.0 : 0.0
    }

    private func offsetVector(for index: Int) -> CGSize {
        let offset = radialOffset(for: index)
        guard offset > 0 else { return .zero }
        let deg = startAngleDeg(for: index) + arcAngleDeg / 2
        let rad = deg * .pi / 180
        let dx = CGFloat(cos(rad)) * offset
        let dy = -CGFloat(sin(rad)) * offset
        return CGSize(width: dx, height: dy)
    }

    var body: some View {
        ZStack {
            ForEach(0..<segmentCount, id: \.self) { index in
                let baseThickness = thickness * 0.55

                // Base thin outline for the segment (always visible)
                SegmentArc(
                    startAngleDeg: startAngleDeg(for: index),
                    arcAngleDeg: arcAngleDeg,
                    ringRadius: ringRadius,
                    thickness: thickness
                )
                .stroke(
                    incompleteColor,
                    style: StrokeStyle(lineWidth: baseThickness, lineCap: .round)
                )

                // Overlay filled, thicker segment for completed / animating state
                SegmentArc(
                    startAngleDeg: startAngleDeg(for: index),
                    arcAngleDeg: arcAngleDeg,
                    ringRadius: ringRadius,
                    thickness: thickness
                )
                .stroke(
                    completedColor,
                    style: StrokeStyle(lineWidth: thickness, lineCap: .round)
                )
                .opacity(completedOpacity(for: index))
                .scaleEffect(scale(for: index))
                .offset(offsetVector(for: index))
            }
        }
    }
}

#Preview("Ring") {
    ZStack {
        Color.black.opacity(0.3).ignoresSafeArea()
        ActionSegmentRingView(
            segmentCount: 8,
            completedCount: 3,
            animatingIndex: nil,
            phase: .settle,
            ringRadius: 120,
            thickness: 12
        )
        .frame(width: 280, height: 280)
    }
}
