//
//  PhraseMatching.swift
//  TimeForABreakSwiftUI
//

import Foundation

/// Pure logic for matching spoken text to break actions and extracting quantities.
/// No audio framework dependencies — fully testable.
enum PhraseMatching {

    struct MatchResult {
        let action: BreakAction
        let quantity: Int?
    }

    // MARK: - Number word mapping (one through fifty)

    private static let numberWords: [String: Int] = [
        "one": 1, "two": 2, "three": 3, "four": 4, "five": 5,
        "six": 6, "seven": 7, "eight": 8, "nine": 9, "ten": 10,
        "eleven": 11, "twelve": 12, "thirteen": 13, "fourteen": 14, "fifteen": 15,
        "sixteen": 16, "seventeen": 17, "eighteen": 18, "nineteen": 19, "twenty": 20,
        "twenty-one": 21, "twenty-two": 22, "twenty-three": 23, "twenty-four": 24, "twenty-five": 25,
        "twenty-six": 26, "twenty-seven": 27, "twenty-eight": 28, "twenty-nine": 29, "thirty": 30,
        "thirty-one": 31, "thirty-two": 32, "thirty-three": 33, "thirty-four": 34, "thirty-five": 35,
        "thirty-six": 36, "thirty-seven": 37, "thirty-eight": 38, "thirty-nine": 39, "forty": 40,
        "forty-one": 41, "forty-two": 42, "forty-three": 43, "forty-four": 44, "forty-five": 45,
        "forty-six": 46, "forty-seven": 47, "forty-eight": 48, "forty-nine": 49, "fifty": 50
    ]

    // MARK: - Quantity Extraction

    /// Extracts a numeric quantity from spoken text.
    /// Tries digit regex first (e.g. "20"), then English number words (e.g. "twenty").
    static func extractQuantity(from text: String) -> Int? {
        // Try digit regex first
        if let match = text.range(of: #"\b(\d+)\b"#, options: .regularExpression) {
            let digits = String(text[match])
            if let value = Int(digits), value > 0 {
                return value
            }
        }

        // Try English number words (longest first to match "twenty-one" before "twenty")
        let lowercased = text.lowercased()
        let sortedWords = numberWords.sorted { $0.key.count > $1.key.count }
        for (word, value) in sortedWords {
            if lowercased.contains(word) {
                return value
            }
        }

        return nil
    }

    // MARK: - Action Matching

    /// Finds the best matching action for spoken text by checking `suggestedPhrases`
    /// and `triggerPhrases`. Matches longest phrases first for specificity
    /// (e.g. "watered plants" matches before "water").
    static func findMatchingAction(spokenText: String, actions: [BreakAction]) -> BreakAction? {
        let lowercased = spokenText.lowercased()

        // Build a list of (phrase, action) pairs, sorted longest first
        var candidates: [(phrase: String, action: BreakAction)] = []

        for action in actions {
            for phrase in action.suggestedPhrases {
                candidates.append((phrase: phrase.lowercased(), action: action))
            }
            for phrase in action.triggerPhrases {
                candidates.append((phrase: phrase.lowercased(), action: action))
            }
        }

        candidates.sort { $0.phrase.count > $1.phrase.count }

        for candidate in candidates {
            if lowercased.contains(candidate.phrase) {
                return candidate.action
            }
        }

        return nil
    }

    // MARK: - Full Transcript Processing

    /// Combines quantity extraction and action matching.
    /// Falls back to `defaultQuantity` for quantifiable actions when no number is spoken.
    static func processTranscript(_ text: String, actions: [BreakAction]) -> MatchResult? {
        guard let action = findMatchingAction(spokenText: text, actions: actions) else {
            return nil
        }

        var quantity = extractQuantity(from: text)

        // Fall back to defaultQuantity for quantifiable actions
        if quantity == nil && action.isQuantifiable {
            quantity = action.defaultQuantity
        }

        return MatchResult(action: action, quantity: quantity)
    }
}
