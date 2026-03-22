//
//  OptionsModel.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-15.
//

import Combine
import SwiftUI

/// Feedback when the timer segment completes (in-app). Mutually exclusive with sound vs haptic.
enum TimerCompletionFeedback: String, Codable, CaseIterable {
    case none
    case sound
    case haptic

    var pickerLabel: String {
        switch self {
        case .none: return "Off"
        case .sound: return "Sound"
        case .haptic: return "Vibration"
        }
    }
}

/// Serializable user preference set controlling timer durations and audio behavior.
struct OptionSet: Codable, Equatable {
    var breaktimeMin: Int
    var worktimeMin: Int
    /// When the work/break segment ends in-app: off, sound, or haptic.
    var completionFeedback: TimerCompletionFeedback = .haptic
    /// Spoken suggestions after a work segment (separate from completion sound/haptic).
    var speakBreakSuggestions: Bool = false

    /// Optional titles for the daily suggested actions set.
    /// If nil or empty, `DataProvider.defaultDailySuggestedActionTitles()` is used.
    var dailySuggestedTitles: [String]? = nil

    /// Number of action ring segments (daily goal). 5...10. Applies from the next day.
    var dailyActionGoal: Int = 5

    /// When false, do not start or keep a Live Activity on the lock screen / Dynamic Island.
    var liveActivityEnabled: Bool = true

    /// When false, hide the next-action text line on the Live Activity (voice/TTS unchanged).
    var liveActivityShowsNextAction: Bool = true

    init(
        breaktimeMin: Int,
        worktimeMin: Int,
        completionFeedback: TimerCompletionFeedback = .haptic,
        speakBreakSuggestions: Bool = false,
        dailySuggestedTitles: [String]? = nil,
        dailyActionGoal: Int = 5,
        liveActivityEnabled: Bool = true,
        liveActivityShowsNextAction: Bool = true
    ) {
        self.breaktimeMin = breaktimeMin
        self.worktimeMin = worktimeMin
        self.completionFeedback = completionFeedback
        self.speakBreakSuggestions = speakBreakSuggestions
        self.dailySuggestedTitles = dailySuggestedTitles
        self.dailyActionGoal = min(10, max(5, dailyActionGoal))
        self.liveActivityEnabled = liveActivityEnabled
        self.liveActivityShowsNextAction = liveActivityShowsNextAction
    }

    /// Test / legacy convenience: `doesPlaySounds` maps to sound feedback only.
    init(
        breaktimeMin: Int,
        worktimeMin: Int,
        doesPlaySounds: Bool,
        dailySuggestedTitles: [String]? = nil,
        dailyActionGoal: Int = 5
    ) {
        self.init(
            breaktimeMin: breaktimeMin,
            worktimeMin: worktimeMin,
            completionFeedback: doesPlaySounds ? .sound : .none,
            speakBreakSuggestions: false,
            dailySuggestedTitles: dailySuggestedTitles,
            dailyActionGoal: dailyActionGoal
        )
    }

    enum CodingKeys: String, CodingKey {
        case breaktimeMin
        case worktimeMin
        case doesPlaySounds
        case isMuted
        case completionFeedback
        case speakBreakSuggestions
        case dailySuggestedTitles
        case dailyActionGoal
        case liveActivityEnabled
        case liveActivityShowsNextAction
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        breaktimeMin = try container.decode(Int.self, forKey: .breaktimeMin)
        worktimeMin = try container.decode(Int.self, forKey: .worktimeMin)

        let doesPlaySounds = try container.decodeIfPresent(Bool.self, forKey: .doesPlaySounds) ?? false
        let legacyMuted: Bool
        if let saved = try container.decodeIfPresent(Bool.self, forKey: .isMuted) {
            legacyMuted = saved
        } else {
            legacyMuted = !doesPlaySounds
        }

        if let cf = try container.decodeIfPresent(TimerCompletionFeedback.self, forKey: .completionFeedback) {
            completionFeedback = cf
        } else {
            completionFeedback = legacyMuted ? .none : .sound
        }

        if let sp = try container.decodeIfPresent(Bool.self, forKey: .speakBreakSuggestions) {
            speakBreakSuggestions = sp
        } else {
            speakBreakSuggestions = !legacyMuted
        }

        dailySuggestedTitles = try container.decodeIfPresent([String].self, forKey: .dailySuggestedTitles)
        let raw = try container.decodeIfPresent(Int.self, forKey: .dailyActionGoal) ?? 5
        dailyActionGoal = min(10, max(5, raw))

        liveActivityEnabled = try container.decodeIfPresent(Bool.self, forKey: .liveActivityEnabled) ?? true
        liveActivityShowsNextAction = try container.decodeIfPresent(Bool.self, forKey: .liveActivityShowsNextAction) ?? true
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(breaktimeMin, forKey: .breaktimeMin)
        try container.encode(worktimeMin, forKey: .worktimeMin)
        try container.encode(completionFeedback, forKey: .completionFeedback)
        try container.encode(speakBreakSuggestions, forKey: .speakBreakSuggestions)
        try container.encode(completionFeedback == .sound, forKey: .doesPlaySounds)
        try container.encode(!speakBreakSuggestions, forKey: .isMuted)
        try container.encodeIfPresent(dailySuggestedTitles, forKey: .dailySuggestedTitles)
        try container.encode(dailyActionGoal, forKey: .dailyActionGoal)
        try container.encode(liveActivityEnabled, forKey: .liveActivityEnabled)
        try container.encode(liveActivityShowsNextAction, forKey: .liveActivityShowsNextAction)
    }
}

/// Observable wrapper around `OptionSet` with disk persistence and helper logic
/// (for example the effective action ring segment count for the current day).
class OptionsModel: ObservableObject {

    static let defaultOptions = OptionSet(
        breaktimeMin: 5,
        worktimeMin: 20,
        completionFeedback: .haptic,
        speakBreakSuggestions: false,
        dailySuggestedTitles: DataProvider.defaultDailySuggestedActionTitles()
    )

    private let persistence = PersistenceManager<OptionSet>(fileName: "options", defaultValue: OptionsModel.defaultOptions)

    @Published var options: OptionSet = defaultOptions

    func setDefault() {
        options = OptionsModel.defaultOptions
        saveToDisk()
    }

    func save(options: OptionSet) async throws {
        try await persistence.save(data: options)
    }

    func load() async throws -> OptionSet {
        try await persistence.load()
    }

    func saveToDisk() {
        persistence.saveToDisk(data: options)
    }

    // MARK: - Action ring segment count (effective for “today”; new goal applies next day)

    private static let actionRingEffectiveDayKey = "actionRingEffectiveDay"
    private static let actionRingSegmentCountKey = "actionRingSegmentCount"

    /// Segment count to show in the action ring today. Updated only when the calendar day changes.
    func effectiveSegmentCountForToday(calendar: Calendar = .current) -> Int {
        let today = calendar.startOfDay(for: Date())
        let defaults = UserDefaults.standard
        let storedDay = defaults.object(forKey: Self.actionRingEffectiveDayKey) as? Date
        let storedCount = defaults.integer(forKey: Self.actionRingSegmentCountKey)
        if storedCount > 0, let d = storedDay, calendar.isDate(d, inSameDayAs: today) {
            return storedCount
        }
        let count = min(10, max(5, options.dailyActionGoal))
        defaults.set(today, forKey: Self.actionRingEffectiveDayKey)
        defaults.set(count, forKey: Self.actionRingSegmentCountKey)
        return count
    }
}
