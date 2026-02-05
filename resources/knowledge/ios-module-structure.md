# Modules structure of the iOS project

## The default iOS app (module) structure is as follows

Read `<project_context>...</project_context>` section in the triggering prompt, and parse available fields in the JSON struct:

- IOS_APP_NAME

```
iOS
|- App
   |- ${IOS_APP_NAME} // Executable iOS App Target
   |  |- AppDelegate.swift
   |  |- SceneDelegate.swift
   |  |- ... (rest of the app target files)
   |- xcodegen.yml
   |- ${IOS_APP_NAME}.xcodeproj  // Generated from xcodegen.yml, do not edit.
|- Libraries
   |- ${IOS_APP_NAME}Main // The Main SPM module, containing the top-level RIBs, and immediate children.
   |- Theming
   |- ... // The rest of the 1-st party app-specific dependencies.
|- SharedLibraries
   |- CloudStorage
   |- Diagnostics
   |- ... // The rest of the 1-st party shared dependencies.
```

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
