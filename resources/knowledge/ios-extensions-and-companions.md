# iOS Extensions, Widgets, and Companion Apps

## When RIBs Does NOT Apply

The RIBs architecture (see `ios-RIBs.md`) is mandatory for the **main iOS app target**. However, Apple's platform extensions and companion targets have their own lifecycle models, UI constraints, and architectural requirements that make RIBs either impossible or counterproductive. These targets MUST follow Apple-native patterns instead.

### Scope Summary

| Target Type                          | Use RIBs?           | Recommended Pattern                                |
| ------------------------------------ | ------------------- | -------------------------------------------------- |
| Main iOS App                         | **YES** (mandatory) | Full RIBs (Router, Interactor, Builder, Presenter) |
| WidgetKit (Home/Lock Screen Widgets) | **NO**              | SwiftUI `Widget` + `TimelineProvider`              |
| Live Activities (ActivityKit)        | **NO**              | `ActivityAttributes` + SwiftUI views               |
| watchOS Companion App                | **NO**              | SwiftUI `@main App` + `@Observable`                |
| App Intents / Shortcuts              | **NO**              | Swift structs conforming to `AppIntent`            |
| App Clip                             | **NO**              | SwiftUI `@main App`, minimal navigation            |
| Notification Service Extension       | **NO**              | `UNNotificationServiceExtension` subclass          |
| Notification Content Extension       | **NO**              | SwiftUI view or simple ViewController              |
| Share Extension                      | **NO**              | SwiftUI-based UI with shared logic                 |
| Keyboard Extension                   | **NO**              | `UIInputViewController` + SwiftUI hosting          |
| iMessage Extension                   | **NO**              | `MSMessagesAppViewController` + SwiftUI            |

### Why Not RIBs for Extensions?

RIBs is built around UIKit's `UIViewController` lifecycle, explicit navigation hierarchies, and long-lived interactor scopes. Apple's extensions and companion targets violate these assumptions:

- **No UIViewController**: Widgets, Live Activities, and watchOS use pure SwiftUI with system-managed lifecycles. There is no view controller to wrap in a `UIHostingController`.
- **No navigation**: Widgets and Live Activities are single-view surfaces. There is no router, no child RIBs to attach/detach.
- **Constrained lifecycle**: Extensions run in separate processes with strict memory limits and short lifetimes. RIBs' DI hierarchy and worker lifecycle adds unnecessary overhead.
- **Framework incompatibility**: CombineRIBs targets iOS/UIKit. It does not compile for watchOS, WidgetKit extensions, or other restricted environments.

---

## Existing Module Compatibility (CRITICAL)

**Most existing template SPM modules CANNOT be used by watchOS or WidgetKit targets.** The dependency graph is heavily tied to CombineRIBs (UIKit-only) and Firebase (iOS-only). Before importing any existing module, consult this table:

| Module                | CombineRIBs | Firebase | UIKit | Safe for watchOS? | Safe for WidgetKit? |
| --------------------- | ----------- | -------- | ----- | ----------------- | ------------------- |
| `${IOS_APP_NAME}Main` | YES         | indirect | YES   | NO                | NO                  |
| `Theming`             | no          | no       | YES   | NO                | NO                  |
| `SimpleTheming`       | no          | no       | YES   | NO                | NO                  |
| `SharedUtility`       | YES         | no       | YES   | NO                | NO                  |
| `Storage`             | YES         | YES      | no    | NO                | NO                  |
| `CloudStorage`        | YES         | YES      | no    | NO                | NO                  |
| `FirAppConfigure`     | YES         | YES      | YES   | NO                | NO                  |
| `Diagnostics`         | YES         | no       | no    | NO                | NO                  |
| `RxExtensions`        | no          | no       | no    | **YES**           | **YES**             |
| `StringCodable`       | no          | no       | no    | **YES**           | **YES**             |

**Only `RxExtensions` and `StringCodable` are safe** for cross-platform use. All other modules are blocked by CombineRIBs (which requires UIKit), Firebase, or direct UIKit imports.

### Implications

- You **cannot** import `SharedUtility` in watchOS/WidgetKit code (no `AnyActionHandler` — use SwiftUI-native callbacks instead).
- You **cannot** use `ThemeProviding` in watchOS/WidgetKit (it uses `UIColor`, `UIFont`, `UITraitCollection`). Use SwiftUI-native theming instead (see below).
- You **must create new platform-agnostic SPM modules** for any code shared between the main app and extensions. See "Creating a Shared Module for Extensions" below.
- None of the existing Package.swift files declare `.watchOS(...)` platform support — you cannot simply add a watchOS target and import existing modules.

---

## Shared Principles (All Targets)

Even when not using RIBs, follow these project-wide principles:

1. **SPM modules for shared code**: Business logic, models, networking, and data access shared between the main app and extensions MUST live in **platform-agnostic** SPM modules. These modules must NOT depend on CombineRIBs, UIKit, or any iOS-only framework.
2. **Protocol-based APIs**: Cross-module APIs remain protocol-based. Extensions consume the same service protocols as the main app.
3. **Theming**: The existing `ThemeProviding` system (UIKit-based) does NOT work on watchOS or in WidgetKit. Use SwiftUI-native `Color` and `Font` directly, or create a lightweight SwiftUI-only theme module (see below).
4. **Localization**: Use `xcstrings-tool-plugin` and `Localizable.xcstrings` in each SPM module. Extension targets can reference shared localization modules if those modules don't have UIKit dependencies.
5. **SwiftUI for all new UI**: This rule applies universally, including extensions.

---

## Creating a Shared Module for Extensions

When an extension (watchOS, WidgetKit, etc.) needs to share models, data access, or business logic with the main app, create a **new, platform-agnostic SPM module**.

### Package.swift Template

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SharedModels",
    platforms: [
        .iOS(.v16),
        .watchOS(.v10),     // Add all platforms this module must support
    ],
    products: [
        .library(name: "SharedModels", targets: ["SharedModels"]),
    ],
    dependencies: [
        // ONLY platform-agnostic dependencies here.
        // DO NOT add CombineRIBs, Firebase, or any UIKit-dependent package.
    ],
    targets: [
        .target(
            name: "SharedModels",
            dependencies: [],
            path: "Sources/SharedModels"
        ),
        .testTarget(
            name: "SharedModelsTests",
            dependencies: ["SharedModels"],
            path: "Tests/SharedModelsTests"
        ),
    ]
)
```

### What Goes in a Shared Module

- **Data models**: Codable structs/enums used by both app and extension
- **Service protocols**: Protocol definitions for data access (implementations differ per target)
- **App Groups data access**: `SharedDataStoring` protocol and its `UserDefaults(suiteName:)` implementation
- **Pure business logic**: Calculations, transformations, validation — anything that doesn't touch UIKit
- **ActivityAttributes**: For Live Activities (must be accessible from both app and widget extension)

### What Does NOT Go in a Shared Module

- Anything that imports `UIKit`, `CombineRIBs`, or Firebase
- RIBs components (Builders, Interactors, Routers, Workers)
- `AnyActionHandler` (from SharedUtility — it depends on CombineRIBs)
- `ThemeProviding` or any theming types that use `UIColor`/`UIFont`

### Directory Placement

```
iOS/Libraries/
├── ${IOS_APP_NAME}Main/     # Main app only (has CombineRIBs)
├── SharedModels/             # NEW — platform-agnostic, used by all targets
│   ├── Package.swift         # Declares iOS + watchOS platforms
│   ├── Sources/SharedModels/
│   │   ├── Models/           # Shared Codable types
│   │   └── DataAccess/       # App Groups-backed protocols + implementations
│   └── Tests/SharedModelsTests/
└── Theming/                  # Main app only (has UIKit)
```

### Wiring the Shared Module

1. Add it as a local package in `xcodegen.yml`:

```yaml
packages:
  IOS_APP_NAMEMain:
    path: ../Libraries/IOS_APP_NAMEMain
  SharedModels:
    path: ../Libraries/SharedModels
```

2. Add it as a dependency to both the main app module's `Package.swift` AND the extension target in `xcodegen.yml`:

```yaml
# Main app target
MyApp:
  dependencies:
    - package: IOS_APP_NAMEMain
    - package: SharedModels

# watchOS target
MyAppWatch:
  dependencies:
    - package: SharedModels
```

3. The main app's `${IOS_APP_NAME}Main` module should also add SharedModels as a dependency in its own `Package.swift`.

---

## SwiftUI-Native Theming for Extensions

The existing `ThemeProviding` protocol depends on UIKit and cannot be used in watchOS or WidgetKit. For extension targets, use SwiftUI-native approaches:

### Option 1: Direct SwiftUI Colors/Fonts (Simplest)

```swift
// In the extension target directly — no shared module needed
extension Color {
    static let appPrimary = Color("PrimaryColor")    // From asset catalog
    static let appBackground = Color("BackgroundColor")
}

extension Font {
    static let appTitle = Font.system(.title, weight: .bold)
    static let appBody = Font.system(.body)
}
```

### Option 2: Shared Color/Font Constants (For Multiple Extensions)

If multiple extension targets need consistent theming, add color/font constants to the `SharedModels` module:

```swift
// In SharedModels module — pure SwiftUI, no UIKit
import SwiftUI

public enum AppColors {
    public static let primary = Color(red: 0.2, green: 0.6, blue: 0.4)
    public static let background = Color(red: 0.98, green: 0.98, blue: 0.98)
    public static let labelPrimary = Color.primary
    public static let labelSecondary = Color.secondary
}

public enum AppFonts {
    public static let title = Font.system(.title, weight: .bold)
    public static let body = Font.system(.body)
    public static let caption = Font.system(.caption)
}
```

### Option 3: Shared Asset Catalog

Create an asset catalog in the shared module with named colors that match the main app's design system. This provides light/dark mode support automatically.

---

## WidgetKit (Home Screen & Lock Screen Widgets)

### Architecture

Widgets use a declarative, timeline-based architecture entirely managed by the system. The developer provides:

- A `TimelineProvider` (or `AppIntentTimelineProvider` for interactive widgets) that produces timeline entries
- SwiftUI views for each widget family (`.systemSmall`, `.systemMedium`, `.systemLarge`, `.accessoryCircular`, etc.)
- An `@main WidgetBundle` entry point

### Pattern

```swift
import WidgetKit
import SwiftUI

// 1. Define the timeline entry
struct MyWidgetEntry: TimelineEntry {
    let date: Date
    let title: String
    let value: Int
}

// 2. Provide timeline data
struct MyWidgetProvider: TimelineProvider {
    // Shared data access via App Groups or SPM module
    private let dataStore: SharedDataStoring

    func placeholder(in context: Context) -> MyWidgetEntry {
        MyWidgetEntry(date: .now, title: "Loading...", value: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (MyWidgetEntry) -> Void) {
        let entry = MyWidgetEntry(date: .now, title: dataStore.latestTitle, value: dataStore.latestValue)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MyWidgetEntry>) -> Void) {
        let entry = MyWidgetEntry(date: .now, title: dataStore.latestTitle, value: dataStore.latestValue)
        let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(3600)))
        completion(timeline)
    }
}

// 3. SwiftUI view
struct MyWidgetView: View {
    let entry: MyWidgetEntry

    var body: some View {
        VStack {
            Text(entry.title)
            Text("\(entry.value)")
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// 4. Widget configuration
struct MyWidget: Widget {
    let kind = "MyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MyWidgetProvider()) { entry in
            MyWidgetView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("Shows latest data.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
```

### Data Sharing

Widgets run in a separate process. Share data with the main app via:

- **App Groups** (`UserDefaults(suiteName:)` or shared file containers) — preferred for simple data
- **Core Data with App Groups** — for structured data
- **Shared SPM module** exposing a `SharedDataStoring` protocol with an App Groups-backed implementation

### Key Rules

- Widget views MUST be stateless (no `@State`, no `@ObservedObject`). All data comes from `TimelineEntry`.
- Use `WidgetURL` or `Link` for deep links back to the main app.
- Keep widget targets lightweight — minimize imported dependencies to stay within memory limits.

---

## Live Activities (ActivityKit)

### Architecture

Live Activities display real-time information on the Lock Screen and Dynamic Island. They use:

- `ActivityAttributes` struct defining static and dynamic content
- SwiftUI views for Lock Screen presentation and Dynamic Island states
- `ActivityKit` API to start, update, and end activities from the main app or push notifications

### Pattern

```swift
import ActivityKit
import SwiftUI

// 1. Define attributes (in a shared SPM module so both app and extension can access)
struct DeliveryActivityAttributes: ActivityAttributes {
    // Static data (set at start, never changes)
    struct ContentState: Codable, Hashable {
        // Dynamic data (updated over time)
        var status: String
        var estimatedArrival: Date
    }

    let orderNumber: String
}

// 2. Live Activity views
struct DeliveryLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeliveryActivityAttributes.self) { context in
            // Lock Screen presentation
            VStack {
                Text("Order #\(context.attributes.orderNumber)")
                Text(context.state.status)
                Text(context.state.estimatedArrival, style: .timer)
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded regions
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.status)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.estimatedArrival, style: .timer)
                }
            } compactLeading: {
                Image(systemName: "box.truck")
            } compactTrailing: {
                Text(context.state.estimatedArrival, style: .timer)
            } minimal: {
                Image(systemName: "box.truck")
            }
        }
    }
}
```

### Starting Activities (from the main app)

The main app (which uses RIBs) starts and manages Live Activities. This is the integration point:

```swift
// Inside a RIBs Interactor or Worker in the main app
import ActivityKit

func startDeliveryTracking(orderNumber: String) {
    let attributes = DeliveryActivityAttributes(orderNumber: orderNumber)
    let initialState = DeliveryActivityAttributes.ContentState(
        status: "Preparing",
        estimatedArrival: Date().addingTimeInterval(3600)
    )
    do {
        let activity = try Activity.request(
            attributes: attributes,
            content: .init(state: initialState, staleDate: nil)
        )
        // Store activity.id for later updates
    } catch {
        // Handle error
    }
}
```

### Key Rules

- `ActivityAttributes` MUST be in a shared SPM module (both the app and the widget extension need access).
- Live Activity views follow the same stateless pattern as widgets — all data comes from `ContentState`.
- Dynamic Island layouts have strict size constraints — keep content minimal.

---

## watchOS Companion App

### Architecture

watchOS apps are pure SwiftUI using the `@main App` entry point. There is no UIKit on watchOS (WKHostingController is deprecated). CombineRIBs does not support watchOS.

### Recommended Pattern

Use SwiftUI's native architecture with `@Observable` (iOS 17+ / watchOS 10+) or `ObservableObject`:

```swift
import SwiftUI

// 1. Entry point
@main
struct MyWatchApp: App {
    @State private var appState = WatchAppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
    }
}

// 2. App state (using @Observable for watchOS 10+)
@Observable
class WatchAppState {
    var items: [Item] = []
    var isLoading = false

    private let dataService: DataServiceProtocol

    init(dataService: DataServiceProtocol = WatchDataService()) {
        self.dataService = dataService
    }

    func loadItems() async {
        isLoading = true
        items = await dataService.fetchItems()
        isLoading = false
    }
}

// 3. Views use NavigationStack for navigation
struct ContentView: View {
    @Environment(WatchAppState.self) private var appState

    var body: some View {
        NavigationStack {
            List(appState.items) { item in
                NavigationLink(value: item) {
                    Text(item.title)
                }
            }
            .navigationDestination(for: Item.self) { item in
                DetailView(item: item)
            }
            .navigationTitle("My App")
            .task {
                await appState.loadItems()
            }
        }
    }
}
```

### Communication with the Main App

- **WatchConnectivity**: For real-time message passing between iPhone and Watch
- **App Groups + CloudKit/iCloud**: For shared persistent data
- **Shared SPM modules**: For models, data protocols, and business logic

### HealthKit on watchOS

watchOS apps commonly use HealthKit for workout sessions and health data. This requires specific setup:

**Entitlements** (in xcodegen.yml — see [ios-xcodeproj.md](ios-xcodeproj.md)):

```yaml
entitlements:
  path: MyAppWatch/MyAppWatch.entitlements
  properties:
    com.apple.developer.healthkit: true
    com.apple.developer.healthkit.access: []
```

**Info.plist keys** (in xcodegen.yml `info.properties`):

```yaml
info:
  properties:
    WKApplication: true
    WKRunsIndependentlyOfCompanionApp: true # Required for Xcode 14+ single-target watchOS apps
    WKCompanionAppBundleIdentifier: com.company.myapp
    NSHealthShareUsageDescription: "App needs access to your health data to display metrics."
    NSHealthUpdateUsageDescription: "App needs to save workout data to Health."
```

**Background modes for workout sessions** — If the watch app needs to run workout sessions in the background:

```yaml
info:
  properties:
    WKBackgroundModes:
      - workout-processing
      # Other watchOS background modes:
      # - self-care       (mindfulness/breathing apps)
      # - physical-therapy
```

**HealthKit workout session pattern:**

```swift
import HealthKit

@Observable
class WorkoutManager {
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    var heartRate: Double = 0

    func requestAuthorization() async throws {
        let typesToShare: Set<HKSampleType> = [.workoutType()]
        let typesToRead: Set<HKObjectType> = [
            .quantityType(forIdentifier: .heartRate)!,
            .quantityType(forIdentifier: .activeEnergyBurned)!,
        ]
        try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
    }

    func startWorkout(type: HKWorkoutActivityType) async throws {
        let config = HKWorkoutConfiguration()
        config.activityType = type
        config.locationType = .indoor

        session = try HKWorkoutSession(healthStore: healthStore, configuration: config)
        builder = session?.associatedWorkoutBuilder()
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: config)

        session?.startActivity(with: .now)
        try await builder?.beginCollection(at: .now)
    }
}
```

### WatchConnectivity (iPhone ↔ Watch Communication)

For real-time data transfer between the iOS app and Watch app:

```swift
import WatchConnectivity

class ConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = ConnectivityManager()

    @Published var receivedMessage: [String: Any] = [:]

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // Send message from Watch to iPhone (or vice versa)
    func sendMessage(_ message: [String: Any]) {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(message, replyHandler: nil)
    }

    // Transfer data in background (guaranteed delivery, not real-time)
    func transferUserInfo(_ info: [String: Any]) {
        WCSession.default.transferUserInfo(info)
    }

    // WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {}

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            self.receivedMessage = message
        }
    }

    // iOS-only delegate methods (not needed on watchOS):
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
}
```

> **Note**: Use `#if os(iOS)` / `#if os(watchOS)` for platform-specific code. `WCSession` requires `sessionDidBecomeInactive` and `sessionDidDeactivate` on iOS but not watchOS.

### Key Rules

- Use `@Observable` (watchOS 10+) for state management. Fall back to `ObservableObject` for older targets.
- Use `NavigationStack` with value-based `navigationDestination` for navigation.
- Keep the Watch app lightweight — watchOS has strict memory limits.
- Share models and service protocols via SPM modules, but the Watch app uses its own service implementations (e.g., `WatchDataService` vs `AppDataService`).
- **Cannot import** `SharedUtility`, `Theming`, or any module that depends on CombineRIBs/UIKit. See the module compatibility table above.
- For HealthKit/workout apps, always add both the entitlements AND the Info.plist usage descriptions. Missing either causes runtime crashes or App Store rejection.
- `WKBackgroundModes` in Info.plist is required for workout sessions to continue when the screen turns off.

### Standalone watchOS App (No Companion iOS App)

A user may request a **standalone watchOS-only app** where the main iOS app is unused. In this case the RIBs-based main iOS app target is irrelevant and should be removed from the project configuration.

#### How to Detect Standalone Intent

Ask the user if they say any of:

- "Apple Watch app", "watchOS app", "Watch app" without mentioning iOS features
- "standalone Watch app" or "independent Watch app"
- A use case that is purely wrist-based (e.g., workout tracker, quick-glance utility)

If the intent is ambiguous, ask: _"Should this be a standalone watchOS app, or a companion to the main iOS app?"_

#### What Changes for Standalone watchOS Projects

| Aspect                       | Companion watchOS                       | Standalone watchOS                                    |
| ---------------------------- | --------------------------------------- | ----------------------------------------------------- |
| Main iOS app                 | Active — implements features with RIBs  | **Removed** from xcodegen.yml                         |
| `packages:` in xcodegen.yml  | References iOS SPM modules              | **Deleted** — watchOS target manages own dependencies |
| RIBs architecture            | Mandatory for iOS target                | **Not applicable** — skip RIBs entirely               |
| `${IOS_APP_NAME}Main` module | Primary feature module                  | **Do not modify** — it depends on CombineRIBs/UIKit   |
| Feature code placement       | Both iOS and watchOS targets            | watchOS app directory + platform-agnostic SPM modules |
| Build command                | `run_ios` (builds all targets)          | `run_ios` or `run_ios(targets: ["watchos"])`          |
| Swift version                | Project default                         | Swift 6 recommended                                   |
| Architecture                 | CombineRIBs (iOS), SwiftUI (watchOS)    | SwiftUI + @Observable, flexible as app scales         |
| WatchConnectivity            | Needed for iPhone ↔ Watch communication | Not needed (no companion app)                         |

#### Cleaning Up xcodegen.yml for Standalone watchOS

For standalone watchOS projects, **delete the iOS target definition and the `packages:` section** from `xcodegen.yml`. A watchOS-only project is far better off containing only the watchOS target:

- **Smaller codebase** — no unused iOS boilerplate
- **Faster compilation** — only the watchOS target is built
- **Instantaneous installation** — Watch simulator deploys quickly
- **No confusion** — agents won't accidentally try to build the iOS target

The build pipeline automatically detects that no iOS targets exist and skips iOS build+deploy. An unparameterized `run_ios` call works correctly — it builds only what's present.

#### Recording the App Type in AGENTS.md

When a standalone watchOS project is confirmed, update the project's `AGENTS.md` file with an `## App Type` section:

```markdown
## App Type

- **Primary platform**: watchOS (standalone)
- **iOS app target**: Removed from xcodegen.yml
- **Architecture**: SwiftUI + @Observable, Swift 6 (no RIBs)
```

This ensures all agents working on the project (including standalone CLI agents that read `AGENTS.md`) understand the project type and skip RIBs-related guidance.

#### Module Placement for Standalone watchOS

```
iOS/
├── App/
│   ├── ${IOS_APP_NAME}Watch/     # watchOS target — ALL feature code goes here
│   └── xcodegen.yml              # Only contains the watchOS target
├── Libraries/
│   └── SharedModels/              # Platform-agnostic models (optional)
```

The `${IOS_APP_NAME}/` iOS app directory and `${IOS_APP_NAME}Main/` module can remain on disk (they are harmless) but should not be modified or referenced from xcodegen.yml.

#### Architecture for Standalone watchOS

watchOS targets can use **Swift 6** and the agent has full flexibility to decide architecture as the app scales:

- **Small apps**: Direct SwiftUI views with `@Observable` view models — no architecture framework needed
- **Medium apps**: MVVM or similar lightweight pattern for separation of concerns
- **Large apps**: Agent's choice — the only constraint is SwiftUI + @Observable as the UI layer

There is no mandatory architecture pattern for watchOS beyond SwiftUI + @Observable.

#### Building Standalone watchOS

Use the MCP tools to discover targets and build selectively:

1. **Discover targets**: Call `list_targets` to confirm watchOS target exists and get its bundle ID
2. **Build**: Call `run_ios` — the pipeline auto-detects that only watchOS targets exist and skips iOS. You can also explicitly pass `targets: ["watchos"]`.
3. **Verify**: The Watch simulator should boot and install the app

#### Mixed iOS + watchOS Projects

For projects that have **both iOS and watchOS targets**:

- **iOS target**: CombineRIBs architecture and all iOS guidance remain mandatory.
- **watchOS target**: Can use Swift 6 and flexible architecture — no mandatory pattern beyond SwiftUI + @Observable.
- **Building**: `run_ios` builds all, `run_ios(targets: ["ios"])` for iOS only, `run_ios(targets: ["watchos"])` for watchOS only, `run_ios(targets: ["ios", "watchos"])` for explicit both.
- **Shared code**: Platform-agnostic models in SPM modules under `Libraries/`. Respect the module compatibility table above — not all modules are safe for watchOS.

---

## App Intents / Shortcuts

### Architecture

App Intents are pure Swift structs. No UI lifecycle, no view controllers. They expose app actions to Shortcuts, Spotlight, and Siri.

### Pattern

```swift
import AppIntents

struct OpenItemIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Item"
    static var description: IntentDescription = "Opens a specific item in the app."

    @Parameter(title: "Item")
    var item: ItemEntity

    func perform() async throws -> some IntentResult {
        // Use shared business logic from SPM module
        let service = ItemService()
        try await service.markAsViewed(item.id)
        return .result()
    }
}

// Entity for Spotlight / parameter resolution
struct ItemEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Item")
    static var defaultQuery = ItemQuery()

    var id: UUID
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }

    let title: String
}
```

### Key Rules

- App Intents MUST use shared SPM modules for business logic — they should NOT duplicate data access code.
- Keep intents focused and atomic. Each intent performs one action.
- Use `@Parameter` with entity types for Spotlight/Siri integration.

---

## App Clips

### Architecture

App Clips are lightweight versions of the app. While they _could_ use RIBs, the overhead is rarely justified for their deliberately simple, single-purpose flows.

### Recommended Pattern

Use SwiftUI `@main App` with minimal navigation:

```swift
@main
struct MyAppClip: App {
    var body: some Scene {
        WindowGroup {
            AppClipFlow()
        }
    }
}

struct AppClipFlow: View {
    @State private var step: ClipStep = .welcome

    var body: some View {
        switch step {
        case .welcome:
            WelcomeView(onContinue: { step = .action })
        case .action:
            ActionView(onComplete: { step = .done })
        case .done:
            CompletionView()
        }
    }
}
```

### Key Rules

- App Clips have a **10 MB size limit** — minimize dependencies aggressively.
- Share business logic via SPM modules, but only import what's needed.
- App Clips should guide users to install the full app. Use `SKOverlay` for the install banner.

---

## Notification Extensions

### Notification Service Extension

Modifies notification content before display (e.g., downloading images, decrypting payloads). No UI.

```swift
import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        guard let mutableContent = request.content.mutableCopy() as? UNMutableNotificationContent else {
            contentHandler(request.content)
            return
        }

        // Modify content using shared utilities
        mutableContent.title = processTitle(mutableContent.title)
        contentHandler(mutableContent)
    }
}
```

### Notification Content Extension

Displays custom UI for notifications. Use SwiftUI:

```swift
import SwiftUI
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    override func viewDidLoad() {
        super.viewDidLoad()
        let hostingController = UIHostingController(rootView: NotificationContentView())
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.frame = view.bounds
        hostingController.didMove(toParent: self)
    }

    func didReceive(_ notification: UNNotification) {
        // Update view with notification content
    }
}
```

---

## Share Extension

Single-purpose UI for receiving shared content from other apps.

```swift
import SwiftUI
import UniformTypeIdentifiers

@main
struct ShareExtension: App {
    var body: some Scene {
        ShareExtensionScene()
    }
}

// Or use the traditional approach with SLComposeServiceViewController
// for basic text/URL sharing
```

---

## Project Structure for Extensions

Extensions and companion targets live alongside the main app but outside the `Libraries/` SPM modules:

```
iOS
├── App
│   ├── ${IOS_APP_NAME}/          # Main app target (minimal bootstrap)
│   ├── ${IOS_APP_NAME}Widget/    # WidgetKit extension target
│   ├── ${IOS_APP_NAME}Watch/     # watchOS companion app
│   ├── ${IOS_APP_NAME}Intents/   # App Intents extension (if separate)
│   ├── ${IOS_APP_NAME}Clip/      # App Clip target
│   └── xcodegen.yml              # All targets configured here
├── Libraries                      # App-specific SPM modules (used by ALL targets)
│   ├── ${IOS_APP_NAME}Main/      # Main app RIBs and features
│   ├── SharedModels/              # Models shared across app + extensions
│   └── Theming/                   # Design system
└── SharedLibraries                # Shared utility SPM modules
    ├── SharedUtility/
    └── ...
```

### xcodegen.yml — Adding Extension Targets

Each extension target is configured in `xcodegen.yml`. See [ios-xcodeproj.md](ios-xcodeproj.md) for:

- **Complete xcodegen.yml examples** for watchOS, WidgetKit, and other extension targets
- **Entitlements schema** (CRITICAL: requires both `path` and `properties`)
- **Info.plist seed templates** for each target type (watchOS, WidgetKit, Notification Service)
- **Common XcodeGen pitfalls** and how to avoid them

#### Quick Reference: Target Type Configuration

| Target Type                     | `type`                                  | `platform` | Key Info.plist Properties                                                                          |
| ------------------------------- | --------------------------------------- | ---------- | -------------------------------------------------------------------------------------------------- |
| watchOS App (Xcode 14+)         | `application`                           | `watchOS`  | `WKApplication: true`, `WKRunsIndependentlyOfCompanionApp: true`, `WKCompanionAppBundleIdentifier` |
| WidgetKit Extension (Xcode 15+) | `extensionkit-extension`                | `iOS`      | `NSExtension.NSExtensionPointIdentifier`, `EXAppExtensionAttributes.EXExtensionPointIdentifier`    |
| WidgetKit Extension (legacy)    | `app-extension`                         | `iOS`      | `NSExtension.NSExtensionPointIdentifier: com.apple.widgetkit-extension`                            |
| Notification Service            | `app-extension`                         | `iOS`      | `NSExtension.NSExtensionPointIdentifier: com.apple.usernotifications.service`                      |
| Share Extension                 | `app-extension`                         | `iOS`      | `NSExtension.NSExtensionPointIdentifier: com.apple.share-services`                                 |
| App Clip                        | `application.on-demand-install-capable` | `iOS`      | `NSAppClip.NSAppClipRequestEphemeralUserNotification: false`                                       |

> **Important**: For watchOS app targets, always use `platform: watchOS` — never `supportedDestinations: [watchOS]`. XcodeGen silently omits the `Embed Watch Content` build phase when `supportedDestinations` is used for watchOS apps. See [ios-xcodeproj.md](ios-xcodeproj.md) for full details.

### Key Rules for Extension Targets

- Extension bundle identifiers MUST be prefixed with the main app's bundle identifier (e.g., `com.company.app.widget`, `com.company.app.watchkitapp`).
- Extensions share code via SPM modules, NOT by adding source files to multiple targets.
- Each extension target is configured in `xcodegen.yml` — do NOT edit `.xcodeproj` directly.
- App Groups entitlements are required for data sharing between the main app and extensions.
- **Entitlements blocks MUST include both `path` and `properties`** — see [ios-xcodeproj.md](ios-xcodeproj.md) for the schema and common pitfalls.
- **Extension Info.plist files need a full set of standard keys** — do not create minimal plists with only the extension-specific key. Use the seed templates in [ios-xcodeproj.md](ios-xcodeproj.md).

---

## Data Sharing Patterns

### App Groups (Most Common)

```swift
// Shared SPM module providing data access
public protocol SharedDataStoring {
    var latestItems: [Item] { get }
    func saveItems(_ items: [Item])
}

public final class AppGroupDataStore: SharedDataStoring {
    private let defaults: UserDefaults

    public init(groupIdentifier: String = "group.com.company.app") {
        self.defaults = UserDefaults(suiteName: groupIdentifier)!
    }

    public var latestItems: [Item] {
        guard let data = defaults.data(forKey: "items"),
              let items = try? JSONDecoder().decode([Item].self, from: data)
        else { return [] }
        return items
    }

    public func saveItems(_ items: [Item]) {
        let data = try? JSONEncoder().encode(items)
        defaults.set(data, forKey: "items")
    }
}
```

### Integration Point: Main App → Extensions

The main app (using RIBs) writes data that extensions read:

```swift
// In a RIBs Worker in the main app
final class DataSyncWorker: Worker {
    private let dataStore: SharedDataStoring
    private let itemStream: AnyPublisher<[Item], Never>

    override func didStart(_ interactorScope: InteractorScope) {
        super.didStart(interactorScope)

        itemStream
            .sink { [weak self] items in
                self?.dataStore.saveItems(items)
                // Trigger widget refresh
                WidgetCenter.shared.reloadAllTimelines()
            }
            .cancelOnStop(self)
    }
}
```

---

## MCP Tools for Target Management

The following MCP tools help manage build targets:

| Tool           | Purpose                                                                                 | When to Use                                                                                                  |
| -------------- | --------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| `list_targets` | Discover all build targets (iOS, watchOS) and their bundle identifiers without building | Before adding a new extension target, before building, to check existing project configuration               |
| `run_ios`      | Build and run on simulator; accepts optional `targets` parameter                        | Building the project; use `targets: ["watchos"]` to build only watchOS, `targets: ["ios"]` to build only iOS |

**Workflow for adding a watchOS target:**

1. Call `list_targets` to see current targets
2. Edit `xcodegen.yml` to add the watchOS target
3. Create source files for the watchOS app
4. Call `run_ios` with `targets: ["watchos"]` to build and test the Watch app
5. Call `run_ios` with `targets: ["ios", "watchos"]` to verify both targets build together

---

## Checklist: Adding a New Extension Target

1. **Decide target type** — Refer to the scope summary table at the top of this document. If the user wants a standalone watchOS app (no iOS companion), see the "Standalone watchOS App" section above.
2. **Check existing targets** — Call `list_targets` to see what targets already exist and their bundle identifiers.
3. **Check module compatibility** — Consult the module compatibility table. Most existing modules (SharedUtility, Theming, Storage, etc.) CANNOT be imported by watchOS/WidgetKit targets. You will likely need to create a new platform-agnostic SharedModels module.
4. **Create shared SPM module** (if needed) — For models/data shared between app and extension. Must declare all target platforms in Package.swift (e.g., `.iOS(.v16), .watchOS(.v10)`). Must NOT depend on CombineRIBs, UIKit, or Firebase.
5. **Create extension source directory** — Under `iOS/App/${IOS_APP_NAME}<ExtType>/`
6. **Create the seed Info.plist** — Use the appropriate template from [ios-xcodeproj.md](ios-xcodeproj.md). Include ALL standard `CFBundle*` keys plus target-specific keys (e.g., `WKApplication`, `NSExtension`). Do NOT create a minimal plist with only the extension-specific key.
7. **Create `.entitlements` file** (if capabilities needed) — Create an empty plist file at the path you'll declare in `xcodegen.yml`. The entitlements block requires BOTH `path` AND `properties`.
8. **Configure in xcodegen.yml** — Add the target with `type`, `platform`, `sources`, `info` (with `path` and `properties`), `entitlements` (if needed, with `path` and `properties`), `settings` (including `PRODUCT_BUNDLE_IDENTIFIER`, `GENERATE_INFOPLIST_FILE: false`), and `dependencies`. Use the complete examples in [ios-xcodeproj.md](ios-xcodeproj.md) as templates.
9. **Add App Groups entitlement to BOTH targets** — If data sharing is needed, add the same App Group identifier to both the main app's and the extension's entitlements blocks.
10. **Implement using Apple-native patterns** — Follow the patterns in this document, NOT RIBs
11. **Wire data sharing** — Use `SharedDataStoring` or similar protocol backed by App Groups
12. **Build and test** — Use `run_ios` with appropriate `targets` parameter (e.g., `targets: ["watchos"]` for Watch-only builds) to verify the new target compiles and runs.
13. **Record app type in AGENTS.md** — If this is a standalone watchOS app (no iOS companion), update the project's `AGENTS.md` with the app type information so other agents know to skip RIBs.
