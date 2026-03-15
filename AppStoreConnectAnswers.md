# Slipless App Store Connect Answers

## Recommended Category

- Primary category: Health & Fitness
- Secondary category: Lifestyle

Why:
Slipless is a personal habit reduction and recovery tracker. It fits Health & Fitness best because the core use case is behavior change, streak tracking, urges, and daily check-ins. Lifestyle is a good secondary fit.

If you want the most conservative positioning to reduce any medical interpretation risk, Lifestyle is also acceptable as the primary category. My recommendation is still Health & Fitness.

## Recommended Age Rating Answers

Answer the questionnaire honestly based on the current binary.

Recommended declarations:

- User-generated content: No
- Unrestricted web access: No
- Gambling or contests: None
- Medical or treatment claims: None
- Violence: None
- Horror or fear themes: None
- Sexual content or nudity: None
- Profanity or crude humor: None

For substances:

- Alcohol, tobacco, or drug references: Infrequent or mild

Why:
The app contains optional habit presets such as Alcohol and Smoking, but it does not glamorize use, show graphic content, or encourage harmful behavior. These are light references in a recovery-tracking context.

## Recommended Privacy Answers

Based on the current app code, the cleanest App Privacy position is:

- Data Not Collected

Why:
The app stores user-entered data locally on-device and does not send it to your servers or third parties. There is no account system, analytics SDK, ad SDK, or remote backend in the current build.

## Recommended Metadata Choices

- App Name: Slipless: Habit Quit Tracker
- Subtitle: Smoking, drinking, cravings
- Promotional Text: Quit smoking, reduce drinking, or break one habit with a private tracker for streaks, urges, slips, reminders, and real progress.
- Keyword Field: streak,sober,urge,relapse,reduce,alcohol,nicotine,doomscrolling,slips,private,days

## Description Guardrails

Keep these points in the description:

- private by default
- no account required
- local on-device storage
- track slips, urges, streaks, and daily check-ins
- reminders, export, Face ID lock, and Stealth Mode

Avoid these claims:

- medical treatment
- therapy
- diagnosis
- cure
- clinically proven outcomes unless you can substantiate them

## Screenshot Guardrails

- Do not mention widgets in v1 screenshots.
- Do not mention cloud sync or backup.
- Do not imply social or community features.
- Do not show explicit substance imagery.

## Review Notes To Paste

Slipless is a private, local-only habit tracking app for reducing or quitting one habit at a time.

- No login or account is required.
- No analytics SDKs, ad SDKs, or third-party tracking are included.
- All user data is stored locally on-device using SwiftData and UserDefaults.
- Notifications are optional and used only for daily reminders when enabled by the user.
- Face ID lock is optional and uses LocalAuthentication.
- The app does not provide medical advice, diagnosis, or treatment.
- The submitted v1 build does not include the unfinished widget experience in marketing metadata.

## URLs To Use

- Privacy Policy URL: https://robertengel.github.io/Slipless/privacy-policy.html
- Support URL: https://robertengel.github.io/Slipless/support.html