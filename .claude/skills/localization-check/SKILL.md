---
name: localization-check
description: Enforces the project's string localization rules when adding or editing user-facing strings
disable-model-invocation: false
---

# Localization Check
When adding user-facing strings:
1. Add the key to Focused Timer/Focused Timer/Shared/Constants/Localizable.xcstrings
2. In SwiftUI: use string literal → Text("key"), Toggle("key"), etc.
3. In non-SwiftUI (e.g. primaryButtonText): use LocalizedStringResource("key", table: "Localizable")
Never use NSLocalizedString or a wrapper enum.
