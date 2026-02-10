# Modules structure of the iOS project

## The default iOS app (module) structure is as follows

Read `<project_context>...</project_context>` section in the triggering prompt, and parse available fields in the JSON struct:

- IOS_APP_NAME

```
iOS
├── App
│   ├── ${IOS_APP_NAME}/          // Executable iOS App Target
│   │   ├── AppDelegate.swift
│   │   ├── SceneDelegate.swift
│   │   └── ... (rest of the app target files)
│   ├── ${IOS_APP_NAME}Widget/    // WidgetKit extension target (optional)
│   ├── ${IOS_APP_NAME}Watch/     // watchOS companion app (optional)
│   ├── ${IOS_APP_NAME}Clip/      // App Clip target (optional)
│   ├── xcodegen.yml
│   └── ${IOS_APP_NAME}.xcodeproj // Generated from xcodegen.yml, do not edit.
├── Libraries
│   ├── ${IOS_APP_NAME}Main/      // Main SPM module: top-level RIBs and features
│   ├── SharedModels/              // Models shared across app + extensions (optional)
│   ├── Theming/
│   └── ...                        // Other 1st-party app-specific dependencies
└── SharedLibraries
    ├── CloudStorage/
    ├── Diagnostics/
    └── ...                        // Other 1st-party shared dependencies
```

> **Note**: Extension targets (Widget, Watch, Clip, etc.) live under `iOS/App/` as separate directories, each configured as a target in `xcodegen.yml`. They do NOT use RIBs — see [ios-extensions-and-companions.md](ios-extensions-and-companions.md) for patterns and guidance. Shared business logic and models used by both the main app and extensions should live in SPM modules under `Libraries/` or `SharedLibraries/`.

## Top-level app target (`iOS/App/...`)

The top-level iOS App target under `iOS/App/...` is minimal, only containing AppDelegate.swift, SceneDelegate.swift and only
the necessary code to instantiate the Root RIB, launch it from the main UIWindow, and forward app delegate events to the relevant services.

It MUST NOT contain feature code.
The Xcode app target must not be touched, and no updates to it are needed when implementing features.

## Module Placement Rules (CRITICAL)

- All app-specific code (RIBs, Workers, Models) MUST live in designated SPM modules under `Libraries`
- The primary app-specific module is `${IOS_APP_NAME}Main`
  - It initially contains the top-level RIBs (Root, Splash, Main)
- The initial project shows an empty home screen (Main RIB's `MainView`). Plan new features by either:
  - Updating the Main RIB (MainInteractor, MainView) to show the relevant data on the home screen, or
  - Converting it to a TabBar view container (view-less RIB), and
    - Adding new RIBs implementing the feature to the Main SPM module under `iOS/Libraries/${IOS_APP_NAME}Main/Sources/${IOS_APP_NAME}Main/RIBs/`
- NEVER add new RIBs under `iOS/App/...`. The App target only bootstraps the Root RIB and hosts minimal app code.
- If a new library module is justified:
  - Add the new SPM module under `Libraries`
  - Plan to wire the dependencies into the Main SPM module (via dependencies in `Package.swift`)
    - Note, no xcodeproj.yml changes are required, since we're wiring the dependencies via SPM modules.
  - Document it in the plan (Module Name, purpose, dependencies).
- In `plan.md`, validate module path for new RIBs/features adheres to SPM-first rule, and NO code is added to the top-level iOS App target under `iOS/App/...`.

## Extension and Companion Target Placement

Apple platform extensions (Widgets, watchOS, App Clips, Notification extensions, etc.) have their own source directories and target configurations:

- Extension source code lives under `iOS/App/${IOS_APP_NAME}<ExtType>/` (e.g., `iOS/App/${IOS_APP_NAME}Widget/`)
- Each extension is configured as a separate target in `xcodegen.yml`
- Extensions do NOT use RIBs — they follow Apple-native SwiftUI patterns (see [ios-extensions-and-companions.md](ios-extensions-and-companions.md))
- Shared code (models, data access, utilities) used by both the main app and extensions MUST live in SPM modules, NOT be duplicated into extension directories
- Extension bundle identifiers MUST be prefixed with the main app's bundle identifier (e.g., `com.company.app.widget`)
- For data sharing between the main app and extensions, use App Groups (configured via entitlements in `xcodegen.yml`)
- Use `list_targets` MCP tool to discover existing targets before adding new ones

## Standalone watchOS App Variant

For **standalone watchOS projects** (where the iOS app target has been removed from xcodegen.yml), the module structure simplifies:

```
iOS
├── App
│   ├── ${IOS_APP_NAME}Watch/     // watchOS target — ALL feature code here
│   └── xcodegen.yml              // Only contains the watchOS target
├── Libraries
│   └── SharedModels/              // Platform-agnostic shared models (optional)
```

Key differences from the standard layout:

- **iOS target removed from xcodegen.yml** — the `${IOS_APP_NAME}` iOS target definition and the `packages:` section should be deleted from `xcodegen.yml`. This makes the project smaller, compilation faster, and simulator installation instantaneous.
- **Do NOT modify `${IOS_APP_NAME}Main`** — it depends on CombineRIBs/UIKit. The module can remain on disk but is not referenced from xcodegen.yml.
- All feature code goes in `iOS/App/${IOS_APP_NAME}Watch/` or in platform-agnostic SPM modules under `Libraries/`
- Build with `run_ios` — the pipeline auto-detects that only watchOS targets exist and skips iOS. You can also explicitly pass `targets: ["watchos"]`.
- watchOS targets can use **Swift 6** and flexible architecture — no mandatory pattern beyond SwiftUI + @Observable
- The project's `AGENTS.md` should document this as a standalone watchOS project (see [ios-extensions-and-companions.md](ios-extensions-and-companions.md))
