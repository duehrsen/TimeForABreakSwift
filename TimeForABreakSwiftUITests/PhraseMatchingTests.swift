//
//  PhraseMatchingTests.swift
//  TimeForABreakSwiftUITests
//

import Testing
@testable import Time_For_A_Break

struct PhraseMatchingTests {

    // MARK: - Test helpers

    private func makeAction(
        title: String,
        isQuantifiable: Bool = false,
        unit: String? = nil,
        defaultQuantity: Int? = nil,
        triggerPhrases: [String] = [],
        suggestedPhrases: [String] = []
    ) -> BreakAction {
        BreakAction(
            title: title,
            categoryId: "exercise",
            isQuantifiable: isQuantifiable,
            unit: unit,
            defaultQuantity: defaultQuantity,
            triggerPhrases: triggerPhrases,
            suggestedPhrases: suggestedPhrases
        )
    }

    private var sampleActions: [BreakAction] {
        [
            makeAction(
                title: "Do pushups",
                isQuantifiable: true,
                unit: "reps",
                defaultQuantity: 10,
                suggestedPhrases: ["pushups", "push ups", "push-ups", "did pushups", "some pushups"]
            ),
            makeAction(
                title: "Drink water",
                isQuantifiable: true,
                unit: "glasses",
                defaultQuantity: 1,
                suggestedPhrases: ["water", "drank water", "had water", "glass of water", "some water"]
            ),
            makeAction(
                title: "Make tea or coffee",
                isQuantifiable: true,
                unit: "cups",
                defaultQuantity: 1,
                suggestedPhrases: ["tea", "coffee", "made tea", "made coffee", "cup of tea", "cup of coffee"]
            ),
            makeAction(
                title: "Water plants",
                isQuantifiable: false,
                suggestedPhrases: ["watered plants", "water plants", "watered the plants", "plant watering"]
            ),
            makeAction(
                title: "Stretch shoulders",
                isQuantifiable: false,
                suggestedPhrases: ["shoulders", "shoulder", "stretched shoulders", "shoulder stretch"]
            ),
        ]
    }

    // MARK: - extractQuantity tests

    @Test func extractQuantityFromDigits() {
        #expect(PhraseMatching.extractQuantity(from: "I did 20 pushups") == 20)
    }

    @Test func extractQuantityFromSingleDigit() {
        #expect(PhraseMatching.extractQuantity(from: "I drank 3 glasses") == 3)
    }

    @Test func extractQuantityFromNumberWord() {
        #expect(PhraseMatching.extractQuantity(from: "I did twenty pushups") == 20)
    }

    @Test func extractQuantityFromHyphenatedWord() {
        #expect(PhraseMatching.extractQuantity(from: "twenty-five reps done") == 25)
    }

    @Test func extractQuantityReturnsNilForNoNumber() {
        #expect(PhraseMatching.extractQuantity(from: "I did some pushups") == nil)
    }

    @Test func extractQuantityPrefersDigitsOverWords() {
        // "10" appears as digit, "twenty" as word — digit should win
        #expect(PhraseMatching.extractQuantity(from: "I did 10 of the twenty") == 10)
    }

    // MARK: - findMatchingAction tests

    @Test func matchesPushups() {
        let result = PhraseMatching.findMatchingAction(spokenText: "I did 20 pushups", actions: sampleActions)
        #expect(result?.title == "Do pushups")
    }

    @Test func matchesWater() {
        let result = PhraseMatching.findMatchingAction(spokenText: "I drank some water", actions: sampleActions)
        #expect(result?.title == "Drink water")
    }

    @Test func matchesCoffee() {
        let result = PhraseMatching.findMatchingAction(spokenText: "I made coffee", actions: sampleActions)
        #expect(result?.title == "Make tea or coffee")
    }

    @Test func matchesCaseInsensitive() {
        let result = PhraseMatching.findMatchingAction(spokenText: "I DID PUSHUPS", actions: sampleActions)
        #expect(result?.title == "Do pushups")
    }

    @Test func noMatchReturnsNil() {
        let result = PhraseMatching.findMatchingAction(spokenText: "hello world", actions: sampleActions)
        #expect(result == nil)
    }

    @Test func longestPhraseMatchesFirst() {
        // "watered plants" should match "Water plants" (longest match),
        // not "Drink water" (shorter "water" match)
        let result = PhraseMatching.findMatchingAction(spokenText: "I watered plants", actions: sampleActions)
        #expect(result?.title == "Water plants")
    }

    @Test func matchesTriggerPhrases() {
        let actions = [
            makeAction(
                title: "Custom action",
                triggerPhrases: ["my custom phrase"],
                suggestedPhrases: []
            )
        ]
        let result = PhraseMatching.findMatchingAction(spokenText: "I did my custom phrase", actions: actions)
        #expect(result?.title == "Custom action")
    }

    // MARK: - processTranscript tests

    @Test func processTranscriptWithQuantity() {
        let result = PhraseMatching.processTranscript("I did 20 pushups", actions: sampleActions)
        #expect(result?.action.title == "Do pushups")
        #expect(result?.quantity == 20)
    }

    @Test func processTranscriptFallsBackToDefaultQuantity() {
        let result = PhraseMatching.processTranscript("I did some pushups", actions: sampleActions)
        #expect(result?.action.title == "Do pushups")
        #expect(result?.quantity == 10) // defaultQuantity
    }

    @Test func processTranscriptNoQuantityForNonQuantifiable() {
        let result = PhraseMatching.processTranscript("I stretched my shoulders", actions: sampleActions)
        #expect(result?.action.title == "Stretch shoulders")
        #expect(result?.quantity == nil)
    }

    @Test func processTranscriptReturnsNilForNoMatch() {
        let result = PhraseMatching.processTranscript("something unrelated", actions: sampleActions)
        #expect(result == nil)
    }
}
