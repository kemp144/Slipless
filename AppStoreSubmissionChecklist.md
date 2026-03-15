# Slipless App Store Submission Checklist

## Preflight Status

Verified on 2026-03-15:

- iOS simulator build succeeds with `xcodebuild -scheme Slipless -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build`
- Face ID usage description is present in the shipping Info.plist
- App Store demo-data UI has been removed from the shipping app
- The unfinished widget is excluded from the shipping app target
- Reset All Data now clears reminder and Face ID settings back to a clean onboarding state
- Future onboarding dates are clamped so streak and stats cannot go negative

Still requires manual verification before submission:

- Archive and validate a signed Release build in Xcode
- Confirm the live Privacy Policy URL opens publicly
- Confirm the live Support URL opens publicly
- Confirm Face ID prompt text on a real device
- Confirm local reminder permission flow and reminder delivery on a real device
- Confirm Stealth Mode and Face ID lock behavior after backgrounding the app on a real device

## Code and Build

- Verify the signed Release archive succeeds in Xcode.
- Verify Face ID prompt appears with the correct usage description on-device.
- Verify reminders can be enabled and disabled on-device.
- Verify Face ID lock can be enabled and disabled on-device.
- Verify no demo-data UI appears in the release build.
- Verify the release build does not include the unfinished widget target.

## App Store Connect URLs

Publish these files and use their live URLs:

- Privacy Policy URL: `https://robertengel.github.io/Slipless/privacy-policy.html`
- Support URL: `https://robertengel.github.io/Slipless/support.html`

## Review Notes To Paste

Slipless is a private, local-only habit tracking app for reducing or quitting one habit at a time.

- No login or account is required.
- No analytics SDKs or ads are included.
- All data is stored locally on-device.
- Notifications are optional and only used for daily reminders when enabled by the user.
- Face ID lock is optional and uses LocalAuthentication.
- The app does not make medical or treatment claims.

Do not mention widgets in metadata or screenshots for v1.

## Metadata Notes

- Keep screenshots focused on the real in-app experience.
- Do not mention widgets in v1 metadata.
- Do not mention cloud backup unless it exists in the build.
- Use a truthful age rating based on your enabled habit presets.

## Final Upload Order

1. Publish `docs/` to GitHub Pages and confirm both URLs load.
2. Create a signed Archive in Xcode and run Validate App.
3. Upload the build to App Store Connect.
4. Paste the review notes from this file or `AppStoreConnectCopyPaste.md`.
5. Set Privacy to `No, we do not collect data from this app`.
6. Upload the final 6.5-inch screenshots and verify cropping in App Store Connect.
7. Submit only after the build, metadata, URLs, and age rating all match the current app behavior.