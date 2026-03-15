# Slipless App Privacy Labels

## Recommended Selection

Select:

- No, we do not collect data from this app

## Why This Is Correct For The Current Build

- There is no account system.
- There is no backend.
- There are no analytics SDKs.
- There are no ad SDKs.
- Habit data is stored locally using SwiftData.
- Simple preferences are stored locally using UserDefaults.
- Notifications are local notifications only.
- Face ID is handled by LocalAuthentication and is not collected by the app.
- Exports are user-initiated through the iOS share sheet and are not uploaded by the app.

## App Privacy Nutrition Labels Walkthrough

When App Store Connect asks whether you or third-party partners collect data from this app, choose:

- No

That means you should not mark any of these as collected:

- Contact Info
- Health & Fitness
- Financial Info
- Location
- Sensitive Info
- Contacts
- User Content
- Browsing History
- Search History
- Identifiers
- Purchases
- Usage Data
- Diagnostics
- Other Data

## Important Caveat

This recommendation is correct only for the current v1 codebase.

If you later add any of the following, you must revisit the privacy answers:

- Firebase or any analytics SDK
- crash reporting that sends device or usage data off-device
- user accounts
- cloud sync
- remote API storage
- email capture or support forms inside the app
- third-party ads

## Related URLs

- Privacy Policy URL: https://robertengel.github.io/Slipless/privacy-policy.html
- Support URL: https://robertengel.github.io/Slipless/support.html