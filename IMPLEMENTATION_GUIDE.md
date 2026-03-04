# Time for a Break - Implementation Guide

This document contains refactoring tasks and new feature specifications for the TimeForABreakSwiftUI app. Use this as a prompt for Claude Code when implementing on macOS.

---

## Part 1: Refactoring (Code Quality)

### 1.1 Refactor TimerModel to Own the Timer Logic

Currently the timer countdown runs in TimerCountView using Timer.publish, but the state lives in TimerModel. Move the timer into TimerModel so the model owns both state and behavior.

Requirements:
- Use `@MainActor` for thread safety
- Use modern Swift concurrency (`Task`, `async/await`) instead of `Timer.publish`
- Use `private(set)` on `@Published` properties so views can only read, not write
- Add computed properties for `progress` (CGFloat 0-1) and `formattedTime` (String "MM:SS")
- Provide methods: `start()`, `pause()`, `toggle()`, `reset()`, `switchMode()`
- Store the Task in a property so it can be cancelled

Then simplify TimerCountView to just observe the model — remove the `Timer.publish` and `.onReceive` logic.

### 1.2 Extract Duplicate Persistence Code

ActionViewModel, SelectedActionsViewModel, and OptionsModel all have nearly identical persistence code (fileURL, save, load, saveToDisk methods). Create a generic `PersistenceManager<T: Codable>` or use a protocol with default implementation to eliminate this duplication.

### 1.3 Replace fatalError() with Proper Error Handling

Multiple `saveToDisk()` methods call `fatalError()` on failure. Replace these with:
- A `@Published` error property on the view models, OR
- An alert shown to the user

Files affected:
- ActionViewModel.swift (line 83)
- SelectedActionsViewModel.swift (line 109)
- OptionsModel.swift (line 89)

### 1.4 Fix Deprecated APIs

| File | Line | Issue | Fix |
|------|------|-------|-----|
| MainView.swift | 55 | `.onChange(of:perform:)` | Use `.onChange(of:) { oldValue, newValue in }` |
| ActionListView.swift | 144 | `.navigationBarItems(trailing:)` | Use `.toolbar { ToolbarItem(placement:) }` |
| TimerCompletionView.swift | 45, 49 | `UIScreen.main.bounds` | Use `GeometryReader` |
| OptionsView.swift | 48 | `UIScreen.main.bounds` | Use `GeometryReader` |

### 1.5 Clean Up SelectedActionsViewModel

This class has two `@Published` arrays:
- `selectedActions` (line 13) - initialized in init() but never used
- `actions` (line 23) - actually used throughout the app

Remove the unused `selectedActions` property and the initialization in `init()`.

### 1.6 Fix OptionsView Creating Separate ActionViewModel

In OptionsView.swift line 16:
```swift
private var actionVM : ActionViewModel = ActionViewModel()
```

This creates a disconnected instance. Either:
- Use `@EnvironmentObject` if it needs the shared instance
- Remove it if it's not actually needed (the restore functionality is commented out)

### 1.7 Migrate to NavigationStack (iOS 16+)

Replace `NavigationView` with `NavigationStack` in:
- ActionListView.swift
- OptionsView.swift
- SummaryView.swift

### 1.8 Clean Up Code Style

- Rename abbreviated variables: `tM`/`tm` → `timerModel`, `os` → `optionsModel`
- Remove debug `print()` statements
- Remove commented-out code blocks
- Replace magic number `-36000` with a named constant or clearer date logic

### 1.9 Use Modern Async/Await for Persistence

Convert the completion-handler based load/save methods to async/await:

Before:
```swift
func load(completion: @escaping (Result<[BreakAction], Error>)->Void) {
    DispatchQueue.global(qos: .background).async { ... }
}
```

After:
```swift
func load() async throws -> [BreakAction] {
    let data = try Data(contentsOf: fileURL())
    return try JSONDecoder().decode([BreakAction].self, from: data)
}
```

---

## Part 2: New Features - Voice Interaction

### 2.1 Feature Overview

Add voice interaction to make the app more motivational and reduce touch interaction:

1. **Voice Output**: When work timer ends, app speaks a motivational prompt suggesting a break action
2. **Voice Input**: User can speak to log completed actions ("I did 20 pushups")
3. **Live Activity**: Keep app visible on lock screen with timer, action preview, and quick voice button

### 2.2 Design Decisions

| Feature | Decision |
|---------|----------|
| When to speak | Immediately at timer end (default), with option to wait for tap |
| Action selection | Random for now; future: AI-distributed by category |
| Phrase style | Consistent "Time to X" format |
| Mute | Big obvious button, simple toggle |
| Voice matching | User-defined trigger words per action (speak to train) |
| Quantities | Track reps, count up from zero, track daily personal bests |
| Voice feedback | Speak confirmation + visual |
| Misheard input | Show what it heard, let user correct (positive tone) |
| Siri integration | Nice-to-have, not essential for v1 |
| Use context | Hands-free at home, moving around |

---

## Part 3: Data Models

### 3.1 ActionCategory

```swift
struct ActionCategory: Codable, Identifiable {
    var id: String                    // "exercise", "hydration", "chores"
    var displayName: String           // "Exercise", "Stay Hydrated"
    var icon: String                  // SF Symbol name: "figure.walk", "drop.fill"
    var minBreaksBetween: Int         // Don't repeat this category for N breaks
    var maxBreaksBetween: Int         // Must suggest this category within N breaks
    var dailyLimit: Int?              // Optional cap (e.g., max 5 exercise suggestions/day)
}
```

### 3.2 BreakAction (Updated)

```swift
struct BreakAction: Codable, Identifiable {
    var id: UUID
    var title: String                 // "Do pushups"
    var description: String           // "Get your blood flowing with a few pushups"
    var spokenPrompt: String          // "Time to do some pushups!"
    var categoryId: String            // "exercise"

    // Tracking
    var isQuantifiable: Bool          // true = user can report a number
    var unit: String?                 // "reps", "glasses", "seconds", nil if not quantifiable
    var defaultQuantity: Int?         // Suggested amount: 10 (for "do 10 pushups")

    // Voice recognition
    var triggerPhrases: [String]      // User's active phrases (max 3, trained by voice)
    var suggestedPhrases: [String]    // Preset options to help recognition

    // Scheduling
    var timesPerDay: Int?             // nil = unlimited, 1 = suggest once per day max
    var preferredTimeRange: ClosedRange<Int>?  // Hour range: 9...17 (9am-5pm only)

    // Metadata
    var isBuiltIn: Bool               // true = from preset library, false = user-created
    var pinned: Bool                  // Existing field
    var completed: Bool               // Existing field
    var date: Date?                   // Existing field
    var frequency: Int                // Existing field
}
```

### 3.3 ActionCompletion

```swift
struct ActionCompletion: Codable, Identifiable {
    var id: UUID
    var actionId: UUID
    var date: Date
    var quantity: Int?                // 20 (pushups), nil if not quantifiable
    var source: CompletionSource      // .voice, .manual
}

enum CompletionSource: String, Codable {
    case voice
    case manual
}
```

### 3.4 DailyBest (Computed/Display)

```swift
struct DailyBest {
    var actionId: UUID
    var actionTitle: String
    var bestQuantity: Int             // Highest daily total ever
    var bestDate: Date                // When it happened
    var todayQuantity: Int            // Current progress today
}
```

---

## Part 4: Preset Data

### 4.1 Categories

| ID | Display Name | Icon | Min Breaks | Max Breaks | Daily Limit |
|----|--------------|------|------------|------------|-------------|
| `exercise` | Exercise | `figure.strengthtraining.traditional` | 3 | 8 | 5 |
| `ergonomics` | Ergonomics | `eye` | 2 | 4 | — |
| `hydration` | Hydration | `drop.fill` | 2 | 6 | — |
| `chores` | Quick Chores | `house.fill` | 4 | 12 | 3 |
| `mental` | Mental Break | `brain.head.profile` | 2 | 5 | — |

### 4.2 Preset Actions

#### Exercise Category

| Title | Quantifiable | Unit | Default Qty | Spoken Prompt | Suggested Phrases |
|-------|--------------|------|-------------|---------------|-------------------|
| Do pushups | Yes | reps | 10 | "Time to do some pushups!" | pushups, push ups, push-ups, did pushups, some pushups, few pushups, doing pushups |
| Do squats | Yes | reps | 15 | "Time to do some squats!" | squats, squat, did squats, some squats, deep knee bends, knee bends |
| Do jumping jacks | Yes | reps | 20 | "Time to do some jumping jacks!" | jumping jacks, jumping jack, star jumps, did jumping jacks, some jumping jacks |
| Do lunges | Yes | reps | 10 | "Time to do some lunges!" | lunges, lunge, did lunges, walking lunges |
| Do planks | Yes | seconds | 30 | "Time to hold a plank!" | plank, planks, held plank, did plank, plank hold, holding plank |

#### Ergonomics Category

| Title | Quantifiable | Unit | Default Qty | Spoken Prompt | Suggested Phrases |
|-------|--------------|------|-------------|---------------|-------------------|
| Stretch shoulders | No | — | — | "Time to stretch your shoulders!" | shoulders, shoulder, stretched shoulders, shoulder stretch, stretched my shoulders, did shoulders, shoulder rolls |
| Stretch neck | No | — | — | "Time to stretch your neck!" | neck, stretched neck, neck stretch, neck rolls, stretched my neck |
| Stretch back | No | — | — | "Time to stretch your back!" | back, stretched back, back stretch, stretched my back, lower back |
| Stretch wrists | No | — | — | "Time to stretch your wrists!" | wrists, wrist, stretched wrists, wrist stretch, hands, stretched hands |
| Eye relaxation | Yes | seconds | 20 | "Time to relax your eyes!" | eyes, eye, eye relaxation, rested eyes, relaxed eyes, eye break, looked away, 20 20 20, twenty twenty |
| Check posture | No | — | — | "Time to check your posture!" | posture, checked posture, fixed posture, sat up straight, straightened up |

#### Hydration Category

| Title | Quantifiable | Unit | Default Qty | Spoken Prompt | Suggested Phrases |
|-------|--------------|------|-------------|---------------|-------------------|
| Drink water | Yes | glasses | 1 | "Time to drink some water!" | water, drank water, had water, glass of water, some water, hydrated, got water, filled water |
| Make tea or coffee | Yes | cups | 1 | "Time to make yourself a warm drink!" | tea, coffee, made tea, made coffee, cup of tea, cup of coffee, brewed coffee, hot drink, warm drink |

#### Chores Category

| Title | Quantifiable | Unit | Times/Day | Spoken Prompt | Suggested Phrases |
|-------|--------------|------|-----------|---------------|-------------------|
| Take out garbage | No | — | 1 | "Time to take out the garbage!" | garbage, trash, took out garbage, took out trash, rubbish, bin, waste |
| Run dishwasher | No | — | 1 | "Time to run the dishwasher!" | run dishwasher, started dishwasher, dishwasher on, turned on dishwasher, loaded dishwasher |
| Clear dishwasher | No | — | 1 | "Time to clear the dishwasher!" | clear dishwasher, cleared dishwasher, emptied dishwasher, unloaded dishwasher, put away dishes |
| Water plants | No | — | 1 | "Time to water your plants!" | plants, watered plants, water plants, watered the plants, plant watering |
| Quick tidy up | No | — | — | "Time to tidy up a small area!" | tidied, tidy up, tidied up, cleaned up, straightened up, organized, put things away |
| Check mail | No | — | 1 | "Time to check the mail!" | mail, checked mail, got mail, mailbox, got the mail, checked the mail |

#### Mental Break Category

| Title | Quantifiable | Unit | Default Qty | Spoken Prompt | Suggested Phrases |
|-------|--------------|------|-------------|---------------|-------------------|
| Look into distance | Yes | seconds | 20 | "Time to look into the distance!" | looked outside, looked away, looked into distance, looked out window, gazed outside, distance viewing |
| Step outside | No | — | — | "Time to step outside for fresh air!" | went outside, stepped outside, fresh air, got fresh air, outside, balcony, porch |
| Deep breathing | Yes | breaths | 5 | "Time to take some deep breaths!" | breathing, deep breaths, breathed, took deep breaths, breathing exercise, breath work, relaxed breathing |
| Take a short walk | Yes | minutes | 2 | "Time to take a short walk!" | walk, walked, took a walk, went for walk, walking, stroll, walked around |
| Stand and stretch | No | — | — | "Time to stand up and stretch!" | stood up, standing, stretched, got up, stand up, standing break |

---

## Part 5: Voice Recognition Flow

### 5.1 Training Trigger Phrases

When user speaks to train a trigger phrase:

1. Use iOS Speech framework (`SFSpeechRecognizer`) to convert speech to text
2. Match against `suggestedPhrases` using substring matching
3. If match found → auto-save as trigger phrase
4. If no match → show what was heard, let user confirm or retry

```swift
func findMatchingPhrase(spokenText: String, suggestedPhrases: [String]) -> String? {
    let lowercased = spokenText.lowercased()

    for phrase in suggestedPhrases {
        if lowercased.contains(phrase.lowercased()) {
            return phrase
        }
    }

    return nil  // No match, allow custom
}
```

### 5.2 Logging Completions via Voice

User says: "I did 20 pushups"

1. Speech recognition → "i did 20 pushups"
2. Extract number → 20
3. Match remaining text against all action trigger phrases
4. Find match → "pushups" matches "Do pushups" action
5. Create ActionCompletion record
6. Speak feedback: "Got it! 20 pushups logged."
7. Show visual confirmation

### 5.3 When Recognition Fails

- Show what was heard
- Let user correct or retry
- Keep tone positive ("I heard X — is that right?")
- Never silently fail

---

## Part 6: Live Activity Design

### 6.1 Layout

```
┌─────────────────────────────────────────────┐
│  WORK MODE                        12:45     │
│  ━━━━━━━━━━━━━━━━━━━━━━░░░░░░░░░░░░░░░░░░   │
│                                             │
│  ☕ Next: Drink water                  🎤   │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  BREAK TIME                       04:32     │
│  ━━━━━━━━━━━━━━━━━━━░░░░░░░░░░░░░░░░░░░░░   │
│                                             │
│  💪 Time to do some pushups!           🎤   │
└─────────────────────────────────────────────┘
```

### 6.2 Elements

| Element | Description |
|---------|-------------|
| Mode label | "WORK MODE" or "BREAK TIME" (different colors) |
| Timer | Countdown in MM:SS |
| Progress bar | Visual progress through current period |
| Action preview | Icon + next action (work mode) or current prompt (break mode) |
| Quick log button | 🎤 microphone — taps to open voice input |

### 6.3 Colors

- Work mode: Calmer tones (blue/gray)
- Break time: Energetic (orange/green)

---

## Part 7: Implementation Order

Suggested order to implement:

### Phase 1: Refactoring
1. TimerModel refactoring (owns timer logic)
2. Extract duplicate persistence code
3. Replace fatalError() with proper error handling
4. Fix deprecated APIs
5. Clean up unused code

### Phase 2: Data Model Updates
1. Add new fields to BreakAction (spokenPrompt, triggerPhrases, suggestedPhrases, etc.)
2. Create ActionCategory model
3. Create ActionCompletion model
4. Add preset data (categories and actions)
5. Migrate existing user data

### Phase 3: Voice Output
1. Add AVSpeechSynthesizer service
2. Integrate with timer completion
3. Add mute toggle to UI
4. Implement action selection logic (random from category)

### Phase 4: Voice Input
1. Add SFSpeechRecognizer service
2. Create voice input UI (big microphone button)
3. Implement phrase matching logic
4. Add quantity extraction from speech
5. Add spoken + visual feedback

### Phase 5: Live Activity
1. Create Live Activity extension
2. Implement work/break mode displays
3. Add action preview
4. Add quick log button integration

### Phase 6: Polish
1. Personal bests tracking and display
2. Category balancing logic
3. Settings for voice features
4. Siri integration (optional)

---

## Frameworks Needed

| Framework | Purpose |
|-----------|---------|
| `AVFoundation` | Text-to-speech (AVSpeechSynthesizer) |
| `Speech` | Speech recognition (SFSpeechRecognizer) |
| `ActivityKit` | Live Activities |
| `WidgetKit` | Live Activity UI |

---

## Notes

- Target audience: Work-from-home office workers
- Tone: Always positive, encouraging any effort
- Personal bests: Track daily totals only (not single session — avoid strain)
- No streaks: User requested avoiding streak-breaking guilt
- Siri: Nice-to-have for later, in-app voice button is priority
