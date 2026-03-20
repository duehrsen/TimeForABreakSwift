//
//  WelcomeSheetView.swift
//  TimeForABreakSwiftUI
//
//

import SwiftUI

struct WelcomeSheetView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 12) {
                    Text("Make your breaks count")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Set focused work and break timers", systemImage: "hourglass.circle")
                        Label("Plan a few meaningful break actions for today", systemImage: "list.bullet")
                        Label("Log what you do by voice or from a list", systemImage: "mic.fill")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 32)
                }

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text("Let's go!")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .clipShape(Capsule())
                    .shadow(radius: 5)
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDragIndicator(.visible)
        .presentationDetents([.medium, .large])
    }
}
