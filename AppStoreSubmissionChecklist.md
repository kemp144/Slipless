# Slipless App Store Submission Checklist

## Code and Build

- Verify Face ID prompt appears with the correct usage description.
- Verify reminders can be enabled and disabled.
- Verify Face ID lock can be enabled and disabled.
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