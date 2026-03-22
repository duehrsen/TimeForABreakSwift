//
//  SummaryView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-08.
//

import SwiftUI

/// Standalone summary screen (today + yesterday). The main app uses the companion sheet; this remains for previews or deep links.
struct SummaryView: View {
    var body: some View {
        NavigationStack {
            SummaryStatsBody(showYesterday: true)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolbars(title: "Summary")
                }
        }
    }
}
