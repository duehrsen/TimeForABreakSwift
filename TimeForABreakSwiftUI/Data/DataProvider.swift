//
//  DataProvider.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-12.
//

import Foundation

enum DataProvider {

    // MARK: - Categories

    static func presetCategories() -> [ActionCategory] {
        [
            ActionCategory(id: "exercise", displayName: "Exercise", icon: "figure.strengthtraining.traditional", minBreaksBetween: 3, maxBreaksBetween: 8, dailyLimit: 5),
            ActionCategory(id: "ergonomics", displayName: "Ergonomics", icon: "eye", minBreaksBetween: 2, maxBreaksBetween: 4, dailyLimit: nil),
            ActionCategory(id: "hydration", displayName: "Hydration", icon: "drop.fill", minBreaksBetween: 2, maxBreaksBetween: 6, dailyLimit: nil),
            ActionCategory(id: "chores", displayName: "Quick Chores", icon: "house.fill", minBreaksBetween: 4, maxBreaksBetween: 12, dailyLimit: 3),
            ActionCategory(id: "mental", displayName: "Mental Break", icon: "brain.head.profile", minBreaksBetween: 2, maxBreaksBetween: 5, dailyLimit: nil),
        ]
    }

    // MARK: - Preset Actions
    //
    // Built-in action titles follow a verb-first convention so they are
    // easy to speak, recognize via voice, and scan in lists (e.g. "Relax eyes").

    static func presetActions() -> [BreakAction] {
        var actions: [BreakAction] = []

        // Exercise
        actions.append(BreakAction(
            title: "Do pushups", description: "Get your blood flowing with a few pushups",
            spokenPrompt: "Time to do some pushups!", categoryId: "exercise", duration: 4,
            isQuantifiable: true, unit: "reps", defaultQuantity: 10,
            suggestedPhrases: ["pushups", "push ups", "push-ups", "did pushups", "some pushups", "few pushups", "doing pushups"],
            isBuiltIn: true))
        actions.append(BreakAction(
            title: "Do squats", description: "Strengthen your legs with some squats",
            spokenPrompt: "Time to do some squats!", categoryId: "exercise", duration: 4,
            isQuantifiable: true, unit: "reps", defaultQuantity: 15,
            suggestedPhrases: ["squats", "squat", "did squats", "some squats", "deep knee bends", "knee bends"],
            isBuiltIn: true))
        actions.append(BreakAction(
            title: "Do planks", description: "Strengthen your core with a plank hold",
            spokenPrompt: "Time to hold a plank!", categoryId: "exercise", duration: 4,
            isQuantifiable: true, unit: "seconds", defaultQuantity: 30,
            suggestedPhrases: ["plank", "planks", "held plank", "did plank", "plank hold", "holding plank"],
            isBuiltIn: true))

        // Ergonomics
        actions.append(BreakAction(
            title: "Relax eyes", description: "Follow the 20-20-20 rule: look at something 20 feet away for 20 seconds",
            spokenPrompt: "Time to relax your eyes!", categoryId: "ergonomics", duration: 2,
            isQuantifiable: true, unit: "seconds", defaultQuantity: 20,
            suggestedPhrases: ["eyes", "eye", "eye relaxation", "rested eyes", "relaxed eyes", "eye break", "looked away", "20 20 20", "twenty twenty"],
            isBuiltIn: true))
        // Removed individual stretch actions to simplify the list;
        // users can instead use \"Stand and stretch\" as a general stretch.

        // Hydration
        actions.append(BreakAction(
            title: "Drink water", description: "Stay hydrated with a glass of water",
            spokenPrompt: "Time to drink some water!", categoryId: "hydration", duration: 2,
            isQuantifiable: true, unit: "glasses", defaultQuantity: 1,
            suggestedPhrases: ["water", "drank water", "had water", "glass of water", "some water", "hydrated", "got water", "filled water"],
            isBuiltIn: true))
        actions.append(BreakAction(
            title: "Make tea or coffee", description: "Brew yourself a warm drink",
            spokenPrompt: "Time to make yourself a warm drink!", categoryId: "hydration", duration: 5,
            isQuantifiable: true, unit: "cups", defaultQuantity: 1,
            suggestedPhrases: ["tea", "coffee", "made tea", "made coffee", "cup of tea", "cup of coffee", "brewed coffee", "hot drink", "warm drink"],
            isBuiltIn: true))

        // Chores
        actions.append(BreakAction(
            title: "Take out garbage", description: "Bundle up and take out the garbage",
            spokenPrompt: "Time to take out the garbage!", categoryId: "chores", duration: 5,
            suggestedPhrases: ["garbage", "trash", "took out garbage", "took out trash", "rubbish", "bin", "waste"],
            timesPerDay: 1, isBuiltIn: true))
        actions.append(BreakAction(
            title: "Run dishwasher", description: "Load and start the dishwasher",
            spokenPrompt: "Time to run the dishwasher!", categoryId: "chores", duration: 5,
            suggestedPhrases: ["run dishwasher", "started dishwasher", "dishwasher on", "turned on dishwasher", "loaded dishwasher"],
            timesPerDay: 1, isBuiltIn: true))
        actions.append(BreakAction(
            title: "Clear dishwasher", description: "Unload the clean dishes from the dishwasher",
            spokenPrompt: "Time to clear the dishwasher!", categoryId: "chores", duration: 7,
            suggestedPhrases: ["clear dishwasher", "cleared dishwasher", "emptied dishwasher", "unloaded dishwasher", "put away dishes"],
            timesPerDay: 1, isBuiltIn: true))
        actions.append(BreakAction(
            title: "Water plants", description: "Give your plants some water or food",
            spokenPrompt: "Time to water your plants!", categoryId: "chores", duration: 4,
            suggestedPhrases: ["plants", "watered plants", "water plants", "watered the plants", "plant watering"],
            timesPerDay: 1, isBuiltIn: true))
        actions.append(BreakAction(
            title: "Tidy up a space", description: "Tidy up a small area of your home",
            spokenPrompt: "Time to tidy up a small area!", categoryId: "chores", duration: 4,
            suggestedPhrases: ["tidied", "tidy up", "tidied up", "cleaned up", "straightened up", "organized", "put things away", "quick tidy up"],
            isBuiltIn: true))
        actions.append(BreakAction(
            title: "Check mail", description: "Retrieve the mail from the mailbox",
            spokenPrompt: "Time to check the mail!", categoryId: "chores", duration: 5,
            suggestedPhrases: ["mail", "checked mail", "got mail", "mailbox", "got the mail", "checked the mail"],
            timesPerDay: 1, isBuiltIn: true))

        // Mental Break
        actions.append(BreakAction(
            title: "Look into distance", description: "Look at an object at least 50 m away for 20 seconds",
            spokenPrompt: "Time to look into the distance!", categoryId: "mental", duration: 2,
            isQuantifiable: true, unit: "seconds", defaultQuantity: 20,
            suggestedPhrases: ["looked outside", "looked away", "looked into distance", "looked out window", "gazed outside", "distance viewing"],
            isBuiltIn: true))
        actions.append(BreakAction(
            title: "Step outside", description: "Get some fresh air outside",
            spokenPrompt: "Time to step outside for fresh air!", categoryId: "mental", duration: 3,
            suggestedPhrases: ["went outside", "stepped outside", "fresh air", "got fresh air", "outside", "balcony", "porch"],
            isBuiltIn: true))
        actions.append(BreakAction(
            title: "Breathe slowly and deeply", description: "Take slow, deep breaths to relax",
            spokenPrompt: "Time to take some deep breaths!", categoryId: "mental", duration: 2,
            isQuantifiable: true, unit: "breaths", defaultQuantity: 5,
            suggestedPhrases: ["breathing", "deep breaths", "breathed", "took deep breaths", "breathing exercise", "breath work", "relaxed breathing"],
            isBuiltIn: true))
        actions.append(BreakAction(
            title: "Take a short walk", description: "Walk around for a couple of minutes",
            spokenPrompt: "Time to take a short walk!", categoryId: "mental", duration: 3,
            isQuantifiable: true, unit: "minutes", defaultQuantity: 2,
            suggestedPhrases: ["walk", "walked", "took a walk", "went for walk", "walking", "stroll", "walked around"],
            isBuiltIn: true))
        actions.append(BreakAction(
            title: "Stand and stretch", description: "Stand up from your chair and stretch your whole body",
            spokenPrompt: "Time to stand up and stretch!", categoryId: "mental", duration: 2,
            suggestedPhrases: ["stood up", "standing", "stretched", "got up", "stand up", "standing break"],
            isBuiltIn: true))
        return actions
    }

    /// Default set of titles used for the \"Use suggested set\" option
    /// when the user hasn't customized their daily suggested actions.
    static func defaultDailySuggestedActionTitles() -> [String] {
        [
            "Drink water",
            // Simplified: keep general stretch instead of specific shoulders
            "Relax eyes",
            "Stand and stretch",
            "Breathe slowly and deeply",
            "Take a short walk"
        ]
    }

    /// Backward-compatible alias used by restoreDefaultsToDisk().
    static func mockData() -> [BreakAction] {
        presetActions()
    }
}
