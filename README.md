# Slipless - Quit One Habit

Slipless is a private, shame-free iOS app that helps a user quit or reduce one bad habit at a time. It is built with SwiftUI and SwiftData for iOS 17+.

## Features

- **Private by Default:** No login, no cloud, local storage only.
- **Stealth Mode:** Hide habit names on the home screen.
- **Urge Reset Flow:** A 60-second breathing timer to help ride out urges.
- **Slip Log:** Non-judgmental tracking of relapses.
- **Progress Tracking:** Streaks, money saved, time saved.
- **Exports:** Share a progress summary as text or image.

## Project Structure

- `SliplessApp.swift`: Main entry point setting up the SwiftData container.
- `Models/`: Core data models (`HabitProfile`, `SlipEvent`, `UrgeEvent`).
- `ViewModels/`: Business logic (`OnboardingViewModel`).
- `Views/`: SwiftUI views organized by feature (`Home`, `Progress`, `History`, `Settings`).
- `Managers/`: Helpers (`SettingsManager`, `TimeFormatter`).

## Getting Started

1.  **Create a New Xcode Project:**
    -   Open Xcode -> Create New Project -> App.
    -   Name: `Slipless`.
    -   Interface: SwiftUI.
    -   Language: Swift.
    -   Storage: SwiftData (or select None and use our setup).
    
2.  **Copy Files:**
    -   Copy the contents of the `Slipless` folder into your new Xcode project directory.
    -   Ensure all files are added to the App target.

3.  **Run:**
    -   Select a simulator (iPhone 15 Pro recommended) and press Run (Cmd+R).

## Configuration

### Habit Presets & Compliance
The list of habits is defined in `Models/HabitPreset.swift`.
- `isMature`: Flags habits like "Alcohol" or "Porn".
- **App Store Submission:** If you wish to submit a rating-friendly version first, you can modify `HabitPreset.availablePresets` to filter out mature content.

### App Store URLs
Host the contents of the `docs/` folder with GitHub Pages and use these URLs in App Store Connect:
- `https://robertengel.github.io/Slipless/privacy-policy.html`
- `https://robertengel.github.io/Slipless/support.html`

## Architecture

- **MVVM:** Views observe ViewModels or query SwiftData models directly.
- **SwiftData:** Used for all persistence.
- **UI Stack:** SwiftUI-first, with small UIKit interop only for the iOS share sheet.

## License

Private.
