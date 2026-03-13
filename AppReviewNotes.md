# App Review Notes for Slipless

## App Overview
Slipless is a self-improvement utility designed to help users track and reduce one bad habit at a time. It focuses on privacy, simplicity, and non-judgmental support.

## Key Features & Compliance
- **No Medical Claims:** The app does not diagnose, treat, or cure any condition. It is a tracking tool only.
- **Privacy:** No user accounts are required. All data is stored locally on the device using SwiftData. No analytics SDKs are used.
- **Stealth Mode:** Users can hide the name of their habit on the home screen and widgets to protect their privacy in public.
- **Urge Reset:** A simple 60-second breathing timer to help users pause before acting on an urge. This is a mindfulness exercise, not a medical intervention.

## Content Ratings
The app includes optional presets for habits like "Alcohol" or "Porn". These are configurable in the source code.
- If these presets are enabled, the app may warrant a higher age rating (17+).
- The app itself contains no explicit imagery or descriptions.
- The "Stealth Mode" feature ensures that even if a user selects a sensitive habit, it is hidden from casual view.

## Data Storage
- Core Data (via SwiftData) is used for local persistence.
- UserDefaults is used for simple preferences (Stealth Mode toggle).

## Usage Instructions
1.  Launch the app.
2.  Complete the onboarding to select a habit (e.g., "Sugar" or "Custom").
3.  The Home Screen displays the current streak.
4.  Tap "I have an urge" to start the breathing timer.
5.  Tap "Log a slip" to record a setback.
6.  Check "Progress" for stats and milestones.
