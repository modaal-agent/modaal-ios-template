# AGENTS.md — Standalone Agent Guide

This file provides context for AI agents (Claude Code, Cursor, Copilot, etc.) working on this iOS project independently.

## Project Overview

This is an iOS app built with:

- **Architecture**: [CombineRIBs](https://github.com/modaal-agent/CombineRIBs) (Combine-based implementation of Uber's RIBs)
- **Reactive Framework**: Swift Combine (not RxSwift)
- **UI Framework**: SwiftUI (wrapped in UIHostingController for RIBs integration)
- **Build System**: XcodeGen + Swift Package Manager

## Knowledge Base

**Detailed documentation is available at:**
https://github.com/modaal-agent/modaal-ios-template/tree/main/resources/knowledge/

Key documents:

- `ios-RIBs.md` — Complete RIBs architecture guide with code examples
- `ios-RIBs-short.md` — Quick reference for RIBs rules
- `ios-extensions-and-companions.md` — watchOS, WidgetKit, and other extension target patterns (NOT RIBs)
- `ios-module-structure.md` — Project module organization
- `ios-localizable.md` — Localization patterns
- `ios-design-system.md` — UI design guidelines
- `ios-xcodeproj.md` — XcodeGen configuration

**Read these documents before making architectural decisions.**

> **Note**: If the `## App Type` section below indicates a standalone watchOS project, you can skip `ios-RIBs.md` and `ios-RIBs-short.md` — RIBs only applies to the iOS app target. Read `ios-extensions-and-companions.md` instead.

## App Type

> This section is filled in when the project type is decided. It tells agents what architecture to follow.

- **Primary platform**: iOS + watchOS companion (default)
- **iOS app target**: Active — uses RIBs architecture
- **Architecture**: CombineRIBs for iOS, SwiftUI + @Observable for watchOS

<!-- For standalone watchOS projects, replace the above with:
- **Primary platform**: watchOS (standalone)
- **iOS app target**: Removed from xcodegen.yml
- **Architecture**: SwiftUI + @Observable, Swift 6 (no RIBs)

NOTE: For standalone watchOS, delete the iOS target definition and the `packages:` section
from xcodegen.yml. The build pipeline auto-detects watchOS-only projects and skips iOS.
-->

## Project Structure

```
src-ios/
├── App/
│   └── IOS_APP_NAME/        # App target (minimal bootstrap code only)
│       ├── AppDelegate.swift
│       ├── SceneDelegate.swift
│       └── xcodegen.yml     # Xcode project configuration
├── Libraries/
│   ├── IOS_APP_NAMEMain/    # Main app module (RIBs, features)
│   │   └── Sources/.../RIBs/
│   │       ├── Root/        # Root RIB (app entry point)
│   │       ├── Splash/      # Splash screen RIB
│   │       └── Main/        # Main screen RIB
│   └── Theming/             # Design system, colors, fonts
└── SharedLibraries/         # Reusable utilities
    ├── SharedUtility/       # Common helpers (AnyActionHandler, etc.)
    ├── Storage/             # Local storage
    └── ...
```

## Critical Rules

### DO:

- Place all new RIBs under `Libraries/IOS_APP_NAMEMain/Sources/.../RIBs/`
- Use SwiftUI for all new UI (wrapped in UIHostingController)
- Use `AnyActionHandler` for UI event callbacks (from SharedUtility)
- Edit `xcodegen.yml` for app configuration (bundle ID, entitlements, etc.)
- Follow existing code patterns in the codebase

### DO NOT:

- Add code to `App/IOS_APP_NAME/` (it's bootstrap-only)
- Edit `*.xcodeproj` files directly (they are generated)
- Edit `Info.plist` directly (use `xcodegen.yml` instead)
- Modify `.gitignore` unless requested by the user, or adding new build systems, etc.
- Patch dependencies in `.build/` or `SourcePackages/` (ephemeral)
- Use raw closures for UI callbacks (causes retain cycles)

## Building the Project

### Via MCP Tools (Preferred — when using Modaal agent)

```
# Discover available targets and their bundle identifiers
list_targets(projectId: "...")

# Build all configured targets (iOS + watchOS, or watchOS-only if no iOS target in xcodegen.yml)
run_ios(projectId: "...")

# Build only watchOS (for standalone watchOS projects or Watch-focused development)
run_ios(projectId: "...", targets: ["watchos"])

# Build only iOS
run_ios(projectId: "...", targets: ["ios"])

# Build both explicitly
run_ios(projectId: "...", targets: ["ios", "watchos"])
```

> **Note**: The pipeline auto-detects which targets exist in `xcodegen.yml`. For watchOS-only projects (iOS target removed), an unparameterized `run_ios` builds only watchOS and skips iOS automatically.

### Via Command Line (Fallback)

```bash
cd src-ios/App

# Generate Xcode project (required after Package.swift changes)
xcodegen generate

# Build via Xcode
open IOS_APP_NAME.xcodeproj
# Or via command line:
xcodebuild -scheme IOS_APP_NAME -destination 'platform=iOS Simulator,name=iPhone 16'
```

## RIBs Quick Reference

Each RIB consists of:

- `*Builder.swift` — Creates the RIB, contains `*Dependency` and `*Buildable` protocols
- `*Router.swift` — Manages child RIBs, contains `*Interactable` and `*ViewControllable` protocols
- `*Interactor.swift` — Business logic, contains `*Presentable`, `*Routing`, `*Listener` protocols
- `*View.swift` — UI (SwiftUI + UIHostingController), implements `*Presentable` and `*ViewControllable`

### View-having RIB Pattern:

```swift
// In *View.swift
final class ExampleViewController: UIHostingController<ExampleView>, ExamplePresentable, ExampleViewControllable {
    let viewState = ViewState()

    init() {
        super.init(rootView: ExampleView(viewState: viewState))
    }

    // Presentable protocol implementation
    var onButtonTapped: AnyActionHandler<Void>?  // Not raw closure!

    final class ViewState: ObservableObject {
        @Published var title: String = ""
    }
}

struct ExampleView: View {
    @ObservedObject var viewState: ExampleViewController.ViewState
    var onButtonTapped: AnyActionHandler<Void>?

    var body: some View {
        Button(viewState.title) {
            onButtonTapped?.invoke()
        }
    }
}
```

## Copyright Headers

When creating new source files, add:

```swift
// © {YEAR} {OWNER}. All rights reserved.
```

## License

This project is based on the [modaal-ios-template](https://github.com/modaal-agent/modaal-ios-template) (MIT License).
