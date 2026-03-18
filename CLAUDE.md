# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TimeForABreakSwiftUI is an iOS app built with SwiftUI that implements a work/break timer following the Pomodoro-style technique. Users can set work and break intervals, manage a list of break activities, and receive notifications when timers complete.

## Build Commands

Open `TimeForABreakSwift-main/TimeForABreakSwiftUI.xcodeproj` in Xcode. Build and run using Cmd+R or via Product > Run.

## Architecture

### State Management

The app uses `@StateObject` and `@EnvironmentObject` for state management. Five core ObservableObject classes are instantiated in `MainView` and passed down via environment:

- **TimerModel** (`Data/TimerModel.swift`): Manages timer state including work/break times, countdown, and background/foreground transitions
- **ActionViewModel** (`Data/ActionViewModel.swift`): Manages the master list of all available break actions with CRUD operations and persistence
- **SelectedActionsViewModel** (`Data/SelectedActionsViewModel.swift`): Manages the user's selected actions for the current day
- **OptionsModel** (`Data/OptionsModel.swift`): Handles user preferences (work/break durations, sound settings) with persistence
- **NotificationManager** (`NotificationManager.swift`): Handles local notification authorization and scheduling

### Data Model

- **BreakAction** (`Data/BreakAction.swift`): Core data struct representing a break activity with properties for title, description, duration, category, completion status, pinned state, and frequency

### Persistence

ViewModels use JSON encoding/decoding to save data to the app's documents directory:
- `breakActions.data` - all available actions
- `selectedActions.data` - today's selected actions
- `options.data` - user preferences

### External Dependencies

- None beyond the standard Apple frameworks (SwiftUI, ActivityKit, AVFoundation, Speech, UserNotifications).

### View Structure

- **MainView**: Root TabView with Timer, Action List, Summary, and Options tabs
- **TimerCountView**: Main timer display with circular progress indicator
- **ActionListView**: Master list of all available break actions
- **SummaryView**: Shows completed actions and statistics
- **OptionsView**: User preferences configuration

### Key Patterns

- Timer countdown runs via `Timer.publish` in `TimerCountView`, updating `TimerModel.currentTimeRemaining` every second
- Background/foreground handling in `MainView` cancels local timers and schedules system notifications when app moves to background
- Pinned actions are automatically added to selected actions on significant time changes (daily refresh)
