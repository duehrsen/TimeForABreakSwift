//
//  PhraseMatching.swift
//  TimeForABreakSwiftUI
//

import Foundation

/// Pure logic for matching spoken text to break actions and extracting quantities.
/// No audio framework dependencies — fully testable and shared by voice UIs.
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

    // MARK: - Verb normalization and stop words

    /// Common English verbs and their most frequent inflected forms.
    /// Used to normalize both transcript text and candidate phrases so that
    /// "took a walk" still matches a phrase like "take a walk".
    private static let verbVariants: [String: [String]] = [
        "ask": ["ask", "asking", "asked"],
        "bake": ["bake", "baking", "baked"],
        "bring": ["bring", "bringing", "brought"],
        "build": ["build", "building", "built"],
        "call": ["call", "calling", "called"],
        "clean": ["clean", "cleaning", "cleaned"],
        "climb": ["climb", "climbing", "climbed"],
        "close": ["close", "closing", "closed"],
        "cook": ["cook", "cooking", "cooked"],
        "cry": ["cry", "crying", "cried"],
        "dance": ["dance", "dancing", "danced"],
        "dig": ["dig", "digging", "dug"],
        "do": ["do", "doing", "did", "done"],
        "draw": ["draw", "drawing", "drew", "drawn"],
        "drink": ["drink", "drinking", "drank", "drunk"],
        "drive": ["drive", "driving", "drove", "driven"],
        "eat": ["eat", "eating", "ate", "eaten"],
        "explain": ["explain", "explaining", "explained"],
        "fall": ["fall", "falling", "fell", "fallen"],
        "feel": ["feel", "feeling", "felt"],
        "fight": ["fight", "fighting", "fought"],
        "find": ["find", "finding", "found"],
        "finish": ["finish", "finishing", "finished"],
        "fix": ["fix", "fixing", "fixed"],
        "fly": ["fly", "flying", "flew", "flown"],
        "forget": ["forget", "forgetting", "forgot", "forgotten"],
        "get": ["get", "getting", "got", "gotten"],
        "give": ["give", "giving", "gave", "given"],
        "go": ["go", "going", "went", "gone"],
        "grow": ["grow", "growing", "grew", "grown"],
        "hang": ["hang", "hanging", "hung"],
        "hear": ["hear", "hearing", "heard"],
        "help": ["help", "helping", "helped"],
        "hide": ["hide", "hiding", "hid", "hidden"],
        "hit": ["hit", "hitting"],
        "hold": ["hold", "holding", "held"],
        "hop": ["hop", "hopping", "hopped"],
        "hug": ["hug", "hugging", "hugged"],
        "jump": ["jump", "jumping", "jumped"],
        "kick": ["kick", "kicking", "kicked"],
        "know": ["know", "knowing", "knew", "known"],
        "laugh": ["laugh", "laughing", "laughed"],
        "learn": ["learn", "learning", "learned", "learnt"],
        "leave": ["leave", "leaving", "left"],
        "listen": ["listen", "listening", "listened"],
        "live": ["live", "living", "lived"],
        "look": ["look", "looking", "looked"],
        "lose": ["lose", "losing", "lost"],
        "love": ["love", "loving", "loved"],
        "make": ["make", "making", "made"],
        "meet": ["meet", "meeting", "met"],
        "move": ["move", "moving", "moved"],
        "need": ["need", "needing", "needed"],
        "open": ["open", "opening", "opened"],
        "paint": ["paint", "painting", "painted"],
        "play": ["play", "playing", "played"],
        "push": ["push", "pushing", "pushed"],
        "read": ["read", "reading"], // past pronounced differently but same spelling
        "ride": ["ride", "riding", "rode", "ridden"],
        "run": ["run", "running", "ran"],
        "say": ["say", "saying", "said"],
        "see": ["see", "seeing", "saw", "seen"],
        "sell": ["sell", "selling", "sold"],
    ]

    /// Very small stop-word set to de-emphasize these tokens when matching.
    private static let stopWords: Set<String> = [
        "a", "an", "the", "in", "on", "at", "of", "to", "for",
        "and", "or", "but", "with", "from", "up", "down", "out"
    ]

    /// Tokenizes text into words, lowercased, stripping simple punctuation.
    private static func tokenize(_ text: String) -> [String] {
        text
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9\\s]", with: " ", options: .regularExpression)
            .split(whereSeparator: { $0.isWhitespace })
            .map(String.init)
    }

    /// Normalizes verbs in the text so that inflected forms map back to a base verb.
    /// e.g. "I took a walk" -> tokens ["i", "take", "a", "walk"]
    private static func normalizedTokens(_ text: String) -> [String] {
        let raw = tokenize(text)
        return raw.map { token in
            // Keep stop words as-is so phrases that include them still work,
            // but normalize verb forms where we recognize them.
            for (base, variants) in verbVariants {
                if variants.contains(token) {
                    return base
                }
            }
            return token
        }
    }

    /// Normalizes a string back into a space-joined representation for
    /// substring checks that are robust to verb inflection.
    private static func normalizedString(_ text: String) -> String {
        normalizedTokens(text).joined(separator: " ")
    }

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
        let normalizedSpoken = normalizedString(spokenText)

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
            let normalizedPhrase = normalizedString(candidate.phrase)
            if normalizedSpoken.contains(normalizedPhrase) {
                return candidate.action
            }
        }

        return nil
    }

    /// Returns all actions whose suggested/trigger phrases match the spoken text
    /// (after verb normalization). Used to offer the user a list of possible matches.
    static func findMatchingActions(spokenText: String, actions: [BreakAction]) -> [BreakAction] {
        let normalizedSpoken = normalizedString(spokenText)

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

        var matched: [BreakAction] = []
        for candidate in candidates {
            let normalizedPhrase = normalizedString(candidate.phrase)
            if normalizedSpoken.contains(normalizedPhrase) {
                if !matched.contains(where: { $0.id == candidate.action.id }) {
                    matched.append(candidate.action)
                }
            }
        }

        return matched
    }

    // MARK: - Full Transcript Processing

    /// Combines quantity extraction and action matching for a specific action.
    /// Falls back to `defaultQuantity` for quantifiable actions when no number is spoken.
    static func matchResult(for action: BreakAction, in text: String) -> MatchResult {
        var quantity = extractQuantity(from: text)
        if quantity == nil && action.isQuantifiable {
            quantity = action.defaultQuantity
        }
        return MatchResult(action: action, quantity: quantity)
    }

    /// Backwards-compatible helper: returns a single best match if available.
    static func processTranscript(_ text: String, actions: [BreakAction]) -> MatchResult? {
        guard let action = findMatchingAction(spokenText: text, actions: actions) else {
            return nil
        }
        return matchResult(for: action, in: text)
    }
}
