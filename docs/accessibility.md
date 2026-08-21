# Accessibility

Focused Timer uses system accessibility settings and native SwiftUI controls wherever possible. This document records the app's common tasks, implementation support, and the evidence needed before publishing Apple's Accessibility Nutrition Labels.

## Supported experiences

- VoiceOver exposes the current timer type, remaining time, cycle progress, controls, settings, warnings, and release notes with concise labels and values.
- Voice Control can address native buttons, tabs, toggles, pickers, text fields, and navigation links by their visible names.
- Dynamic Type is used throughout the app. The timer becomes scrollable and Settings rows reflow vertically at accessibility text sizes.
- Light and dark appearances use system colors or adaptive asset colors.
- Timer, button, validation, and cycle animations are removed when Reduce Motion is enabled.
- Timer phases, cycle progress, validation errors, and changelog entry types use text, shape, or symbols in addition to color.
- Invalid numeric settings show an icon, explanatory text, and an accessibility value rather than relying on a red border alone.

## Common-task matrix

Apple requires every common task to work with an accessibility feature before that feature is declared in App Store Connect.

| Common task | VoiceOver / Voice Control | Larger Text | Dark Interface | Without Color Alone | Reduced Motion |
|---|---|---|---|---|---|
| Read the current timer, phase, and cycle progress | Automated semantics and audit coverage | Adaptive timer layout | Adaptive colors | Text and shape convey state | Timer transitions are suppressed |
| Start, pause, resume, and reset a timer | Native labeled buttons | Controls remain available | Adaptive colors | Icons have text alternatives | Press animations are suppressed |
| Change timer durations and cycle count | Labeled numeric fields and accessible errors | Rows reflow vertically | Native form appearance | Errors include icon and text | Validation animation is suppressed |
| Change app, alert, and Focus settings | Native pickers and toggles; disabled reasons are provided | Native form reflow | Native form appearance | State is not conveyed by color alone | No required motion |
| Read Help, What's New, and the changelog | Native text, headings, lists, and navigation | Scrollable Dynamic Type text | Adaptive colors | Entry categories include text and symbols | No required motion |

Automated coverage is implemented in `Focused TimerUITests/Accessibility/AccessibilityUITests.swift`, with accessibility-size snapshot coverage in the timer and settings snapshot suites. Before publishing metadata, run those checks and manually complete every row with VoiceOver, Voice Control, Larger Text at 200% or greater, Increase Contrast, Reduce Motion, and Differentiate Without Color enabled on a physical iPhone.

## Accessibility Nutrition Labels

Accessibility Nutrition Labels are App Store Connect metadata; they are not inferred from the app binary. App Store Connect automatically detects supported device families, but an authorized account holder must select and publish the features supported by the app.

After the automated and manual common-task matrix passes, evaluate these iPhone declarations in App Store Connect:

- VoiceOver
- Voice Control
- Larger Text
- Dark Interface
- Differentiate Without Color Alone
- Sufficient Contrast
- Reduced Motion

Captions and Audio Descriptions are not applicable because Focused Timer has no video or spoken-media workflow. Do not publish a declaration whose common-task checks have not passed.

To publish:

1. Open the app in App Store Connect and select **App Accessibility**.
2. Add iPhone support and select only the features verified by the current release's matrix.
3. Save the responses as a draft, review them, and publish.
4. Add the public URL for this page as the optional Accessibility URL.
5. Re-run the matrix and update the declarations whenever accessibility behavior changes.

Apple also provides an App Store Connect API for organizations that already automate release metadata. This repository intentionally does not store API credentials or publish metadata as part of the application build.

Official references:

- [Overview of Accessibility Nutrition Labels](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/overview-of-accessibility-nutrition-labels/)
- [Manage Accessibility Nutrition Labels](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/manage-accessibility-nutrition-labels)
- [Configure accessibility declarations with the App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi/configuring-accessibility-declarations)
