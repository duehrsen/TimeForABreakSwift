//
//  DayPlanSummaryView.swift
//  TimeForABreakSwiftUI
//

import SwiftUI

struct DayPlanSummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var selectActions: SelectedActionsViewModel

    private var todaysActions: [BreakAction] {
        let cal = Calendar.current
        return selectActions.actions.filter {
            cal.isDateInToday($0.date ?? .distantPast)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("You're set for today")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 16)

                Text("Here are the actions you've planned for today.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                List {
                    ForEach(todaysActions, id: \.id) { action in
                        HStack {
                            Text(action.title)
                                .font(.body)
                            Spacer()
                            if action.frequency > 1 {
                                Text("×\(action.frequency)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                Button(action: {
                    dismiss()
                }) {
                    Text("Let's go!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .padding(.bottom, 16)
            }
            .navigationTitle("Today's actions")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
