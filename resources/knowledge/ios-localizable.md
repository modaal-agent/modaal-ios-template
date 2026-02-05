# Localization, Accessibility, and Internationalization

## Localization

All static strings MUST come from `Localizable.xcstrings`.
Localizable string resources (`Localizable.xcstrings`) are only added to individual SPM modules where the localizable keys are being used.

When a new key needs to be added, check that the module has the `Localizable.xcstrings` file added at the sources root, and referenced in the Package.swift file.

Additionally, we're using `xcstrings-tool-plugin` to autogenerate Swift constants for localization resources.

### Folder structure

```
<ModuleName>
  |- Package.swift
  +- Sources
    |- <ModuleName>
    | +- Localizable.xcstrings
    +- <ModuleName>Tests
```

Package.swift:

```
let package = Package(
  dependencies: [
    .package(url: "https://github.com/liamnichols/xcstrings-tool-plugin.git", from: "1.2.0"),
  ],
  targets: [
    .target(
      resources: [
        .process("Localizable.xcstrings"), // <<-- Reference
      ]
    ),
    plugins: [
      .plugin(name: "XCStringsToolPlugin", package: "xcstrings-tool-plugin"),
    ],
  ]
)
```

### Examples

- **NEVER** use added localization keys directly in the code:
  - INCORRECT: `Text("Explore", comment: "The title of the tab bar item that navigates to the Explore screen.")`
- **ALWAYS** use generated constants and provided overrides:
  - CORRECT: `Text(localizable: .splashLogoSubtitle)`
  - CORRECT: `.navigationTitle(LocalizedStringKey(localizable: .splashLogoSubtitle))`
- **DON'T** plan to "update" generated constants file, the build tool plugin regenerates constants automatically on every build.

## Accessibility and Internationalization

- Basic accessibility is REQUIRED: label traits, dynamic type, and hiding of empty content (e.g., optional descriptions).
- Locale-aware sorting MUST be used where applicable.
- Rationale: Ensures inclusive UX and consistent i18n behavior.
