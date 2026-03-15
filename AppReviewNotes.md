# App Review Notes for Slipless

## App Overview
Slipless is a self-improvement utility for tracking and reducing one habit at a time.
It is privacy-first, local-only, and designed to avoid shame-based language.

## Core Review Notes
- No login or account creation is required.
- No subscriptions or in-app purchases are included in this build.
- No analytics SDKs, ad SDKs, or third-party tracking are included.
- All user data is stored locally on-device using SwiftData.
- The app does not make medical, diagnostic, or treatment claims.
- The submitted v1 build does not expose internal demo-data tools.
- The unfinished widget implementation is not included in the shipping app target.

## Feature Summary
- Track one habit with streaks, slips, urges, and daily check-ins.
- View money saved, time reclaimed, milestones, and progress trends.
- Use Urge Reset as a simple 60-second mindfulness flow.
- Export a progress summary as text or image.
- Optional daily reminder notifications.
- Optional Face ID lock for privacy.
- Optional Stealth Mode to hide the habit name on the home screen.

## Notes For Review
- If Face ID lock is enabled, the app uses LocalAuthentication only.
- Notifications are optional and requested only when reminders are enabled by the user.
- The app contains no community, chat, or user-generated content.
- The app works fully without creating an account.

## Content Rating Guidance
The app contains optional habit presets such as Alcohol.
There is no explicit imagery or graphic content, but the final App Store age rating should be answered honestly based on enabled presets and habit themes.

## URLs To Provide In App Store Connect
- Privacy Policy URL: https://robertengel.github.io/Slipless/privacy-policy.html
- Support URL: https://robertengel.github.io/Slipless/support.html
