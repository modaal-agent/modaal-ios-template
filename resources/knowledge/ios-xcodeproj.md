# How to generate the Xcode project (`*.xcodeproj/project.pbxproj` file)

The AI agent (LLM) should NEVER try to generate or edit the top-level Xcode project file (`*.xcodeproj/project.pbxproj`),
as its structure is convoluted and hard to edit/reason about.

Internally, XcodeGen utility is used to generate the actual Xcode project file from the configuration every time the iOS app is being built.
The configuration for the Xcode project file is created during the initial bootstrap.

If absolutely necessary for accomplishing the task at hand, the Xcodegen configuration file could be edited (eg., to specify entitlements, etc).
Defer project generation until later `run_ios` MCP tool call.

## Reference

- XcodeGen: https://github.com/yonaskolb/XcodeGen
- The location of the configuration file: `${TARGET_DIR}/src-ios/App/xcodegen.yml`
- Related MCP tools:
  - `list_targets` — discover available build targets (iOS, watchOS) and their bundle identifiers without running a build. Call this before `run_ios` to check what platforms are configured.
  - `run_ios` — build and run the project on simulator. Accepts an optional `targets` parameter (e.g., `["ios"]`, `["watchos"]`, `["ios", "watchos"]`) to build specific platforms.

## XcodeGen Compatibility with Extensions and Companion Apps

XcodeGen provides **first-class support** for watchOS apps, WidgetKit extensions, and all standard Apple extension target types. Support includes dedicated build setting presets, automatic embed phase generation (`Embed Foundation Extensions`, `Embed Watch Content`, etc.), and active maintenance.

### Supported Target Types (Extension-Related)

| Type String                             | Use Case                                                                            | Embed Phase                   |
| --------------------------------------- | ----------------------------------------------------------------------------------- | ----------------------------- |
| `application`                           | Standard app (iOS, macOS, **watchOS with Xcode 14+**)                               | —                             |
| `application.on-demand-install-capable` | App Clips                                                                           | —                             |
| `application.watchapp2`                 | WatchKit 2 app (**pre-Xcode 14 only**)                                              | Embed Watch Content           |
| `app-extension`                         | Generic app extension (Share, Notification, Today, etc.)                            | Embed Foundation Extensions   |
| `extensionkit-extension`                | Modern ExtensionKit extension (Xcode 14+, **preferred for WidgetKit, App Intents**) | Embed ExtensionKit Extensions |
| `watchkit2-extension`                   | WatchKit 2 extension (**pre-Xcode 14 only**)                                        | Embed Foundation Extensions   |
| `app-extension.intents-service`         | SiriKit Intents extension                                                           | Embed Foundation Extensions   |
| `app-extension.messages`                | iMessage extension                                                                  | Embed Foundation Extensions   |

### Critical: watchOS App Target Configuration

**ALWAYS use `platform: watchOS`**, not `supportedDestinations: [watchOS]`, for watchOS app targets. XcodeGen explicitly validates against this — using `supportedDestinations` for watchOS app targets causes the `Embed Watch Content` build phase to be silently omitted, resulting in a broken build.

**Modern single-target watchOS apps (Xcode 14+)** must use `type: application` with `platform: watchOS`:

```yaml
MyAppWatch:
  type: application # NOT application.watchapp2
  platform: watchOS # NOT supportedDestinations
  deploymentTarget: "11.0"
```

The older `application.watchapp2` + `watchkit2-extension` two-target approach is for **pre-Xcode 14 projects only**. Using `application.watchapp2` with Xcode 14+ single-target builds causes "Multiple commands produce..." errors.

### Critical: WidgetKit Target Type

For modern Xcode (15+), prefer `type: extensionkit-extension` for WidgetKit widgets:

```yaml
MyAppWidget:
  type: extensionkit-extension # Modern — preferred for Xcode 15+
  platform: iOS
```

The older `type: app-extension` also works but has a known device installation issue (XcodeGen [#1327](https://github.com/yonaskolb/XcodeGen/issues/1327)). Both generate correct widget builds, but `extensionkit-extension` uses the newer ExtensionKit embedding mechanism which better matches how Xcode itself creates WidgetKit targets.

---

## XcodeGen Target Configuration Reference

This section documents the XcodeGen schema patterns needed when editing `xcodegen.yml`. When in doubt, refer to the [XcodeGen Spec](https://github.com/yonaskolb/XcodeGen/blob/master/Docs/ProjectSpec.md).

### Entitlements

**CRITICAL**: The `entitlements` block requires BOTH `path` AND `properties`. Omitting `path` causes a decoding error: `"Decoding failed at 'path': Nothing found"`.

#### Schema

```yaml
targets:
  MyApp:
    entitlements:
      path: MyApp/MyApp.entitlements # REQUIRED — path to the .entitlements file (relative to xcodegen.yml)
      properties: # REQUIRED — entitlement key-value pairs
        com.apple.security.app-sandbox: true
        com.apple.developer.healthkit: true
```

#### Steps to add entitlements

1. **Create the `.entitlements` file** at the path specified. The file is a standard plist:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
</dict>
</plist>
```

> Note: The `.entitlements` file can start empty — XcodeGen merges the `properties` from `xcodegen.yml` into it during project generation. However, creating the file is required so XcodeGen can find it at the declared `path`.

2. **Add the `entitlements` block** to the target in `xcodegen.yml` with both `path` and `properties`.

#### Common entitlement keys

| Capability               | Entitlement Key                                                          | Value                                       |
| ------------------------ | ------------------------------------------------------------------------ | ------------------------------------------- |
| App Groups               | `com.apple.security.application-groups`                                  | `["group.com.company.app"]`                 |
| HealthKit                | `com.apple.developer.healthkit`                                          | `true`                                      |
| HealthKit (capabilities) | `com.apple.developer.healthkit.access`                                   | `["health-records"]`                        |
| Push Notifications       | `aps-environment`                                                        | `development` or `production`               |
| iCloud (CloudKit)        | `com.apple.developer.icloud-container-identifiers`                       | `["iCloud.com.company.app"]`                |
| iCloud (services)        | `com.apple.developer.icloud-services`                                    | `["CloudKit"]`                              |
| Sign in with Apple       | `com.apple.developer.applesignin`                                        | `["Default"]`                               |
| Background Modes         | `com.apple.developer.background-modes` (in Info.plist, not entitlements) | —                                           |
| Keychain Sharing         | `keychain-access-groups`                                                 | `["$(AppIdentifierPrefix)com.company.app"]` |

#### Example: App with HealthKit + App Groups (for extension data sharing)

```yaml
targets:
  MyApp:
    type: application
    platform: iOS
    entitlements:
      path: MyApp/MyApp.entitlements
      properties:
        com.apple.developer.healthkit: true
        com.apple.developer.healthkit.access: []
        com.apple.security.application-groups:
          - group.com.company.myapp

  MyAppWatch:
    type: application
    platform: watchOS
    entitlements:
      path: MyAppWatch/MyAppWatch.entitlements
      properties:
        com.apple.developer.healthkit: true
        com.apple.developer.healthkit.access: []
        com.apple.security.application-groups:
          - group.com.company.myapp
```

### Info.plist Configuration

XcodeGen handles Info.plist via the `info` block. Understanding which keys are auto-generated vs which must be explicitly declared avoids both missing-key errors and redundant entries.

#### Schema

```yaml
targets:
  MyTarget:
    info:
      path: MyTarget/Info.plist # Path to seed Info.plist file (relative to xcodegen.yml)
      properties: # Additional or overriding Info.plist keys
        SomeKey: SomeValue
```

#### What XcodeGen auto-generates

XcodeGen automatically sets these keys from the target configuration — do NOT manually add them to `info.properties` or the seed plist unless you need to override:

| Key                             | Source                                                                         |
| ------------------------------- | ------------------------------------------------------------------------------ |
| `CFBundleIdentifier`            | `settings.base.PRODUCT_BUNDLE_IDENTIFIER` (via `$(PRODUCT_BUNDLE_IDENTIFIER)`) |
| `CFBundleExecutable`            | Derived from target name (via `$(EXECUTABLE_NAME)`)                            |
| `CFBundleName`                  | `PRODUCT_NAME` setting (via `$(PRODUCT_NAME)`)                                 |
| `CFBundlePackageType`           | Derived from `type` (e.g., `APPL` for `application`)                           |
| `CFBundleDevelopmentRegion`     | `options.developmentLanguage`                                                  |
| `CFBundleInfoDictionaryVersion` | Always `6.0`                                                                   |

#### What you MUST declare

These keys are NOT auto-generated and must be in `info.properties` or the seed plist if needed:

| Key                                 | When Required            | Example Value                            |
| ----------------------------------- | ------------------------ | ---------------------------------------- |
| `CFBundleVersion`                   | Always (App Store)       | `$(CURRENT_PROJECT_VERSION)`             |
| `CFBundleShortVersionString`        | Always (App Store)       | `$(MARKETING_VERSION)`                   |
| `LSApplicationCategoryType`         | App Store submission     | `public.app-category.health-and-fitness` |
| `UILaunchStoryboardName`            | iOS apps                 | `LaunchScreen`                           |
| `UISupportedInterfaceOrientations`  | iOS apps                 | Array of orientations                    |
| `UIApplicationSceneManifest`        | iOS apps with scenes     | Scene configuration dict                 |
| `NSHealthShareUsageDescription`     | HealthKit                | Usage string                             |
| `NSHealthUpdateUsageDescription`    | HealthKit (write)        | Usage string                             |
| `WKApplication`                     | watchOS apps             | `true`                                   |
| `WKCompanionAppBundleIdentifier`    | watchOS apps             | Main app bundle ID                       |
| `WKRunsIndependentlyOfCompanionApp` | watchOS apps (Xcode 14+) | `true`                                   |

#### Seed Info.plist files

For **iOS app targets**, the template provides a complete seed plist referenced via `info.path`. XcodeGen merges `info.properties` on top of this file.

For **extension and watchOS targets**, you typically need to create a minimal seed plist. The required content varies by target type:

##### watchOS App — Minimal Info.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    <key>CFBundleShortVersionString</key>
    <string>$(MARKETING_VERSION)</string>
    <key>CFBundleVersion</key>
    <string>$(CURRENT_PROJECT_VERSION)</string>
    <key>WKApplication</key>
    <true/>
    <key>WKRunsIndependentlyOfCompanionApp</key>
    <true/>
    <key>WKCompanionAppBundleIdentifier</key>
    <string>MAIN_APP_BUNDLE_ID</string>
</dict>
</plist>
```

> Replace `MAIN_APP_BUNDLE_ID` with the actual main app bundle identifier.

##### WidgetKit Extension — Minimal Info.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    <key>CFBundleShortVersionString</key>
    <string>$(MARKETING_VERSION)</string>
    <key>CFBundleVersion</key>
    <string>$(CURRENT_PROJECT_VERSION)</string>
    <key>NSExtension</key>
    <dict>
        <key>NSExtensionPointIdentifier</key>
        <string>com.apple.widgetkit-extension</string>
    </dict>
</dict>
</plist>
```

##### Notification Service Extension — Minimal Info.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    <key>CFBundleShortVersionString</key>
    <string>$(MARKETING_VERSION)</string>
    <key>CFBundleVersion</key>
    <string>$(CURRENT_PROJECT_VERSION)</string>
    <key>NSExtension</key>
    <dict>
        <key>NSExtensionPointIdentifier</key>
        <string>com.apple.usernotifications.service</string>
        <key>NSExtensionPrincipalClass</key>
        <string>$(PRODUCT_MODULE_NAME).NotificationService</string>
    </dict>
</dict>
</plist>
```

### Adding Extension Targets

Extension targets are added as separate entries under `targets:` in `xcodegen.yml`. Each extension type has specific requirements.

#### Common extension target schema

```yaml
targets:
  MyAppExtName:
    type: app-extension # or "application" for watchOS
    platform: iOS # or "watchOS"
    deploymentTarget: "18.0" # Match or exceed main app
    sources:
      - path: MyAppExtName # Directory containing extension source files
    info:
      path: MyAppExtName/Info.plist
      properties:
        CFBundleVersion: $(CURRENT_PROJECT_VERSION)
        CFBundleShortVersionString: $(MARKETING_VERSION)
        # ... target-type-specific keys
    entitlements: # Only if capabilities are needed
      path: MyAppExtName/MyAppExtName.entitlements
      properties:
        # ... entitlement keys
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.company.app.extname
        MARKETING_VERSION: 1.0.0
        # ... other build settings
    dependencies:
      - target: MyApp # Embed in main app
        embed: false # Extensions are NOT embedded this way
      - package: SharedModels # SPM dependencies
```

#### watchOS Target (complete example)

```yaml
MyAppWatch:
  type: application
  platform: watchOS
  deploymentTarget: "11.0"
  sources:
    - path: MyAppWatch
  info:
    path: MyAppWatch/Info.plist
    properties:
      CFBundleVersion: $(CURRENT_PROJECT_VERSION)
      CFBundleShortVersionString: $(MARKETING_VERSION)
      WKApplication: true
      WKRunsIndependentlyOfCompanionApp: true # Required for Xcode 14+ single-target watchOS apps
      WKCompanionAppBundleIdentifier: com.company.myapp
      # Usage descriptions for capabilities:
      NSHealthShareUsageDescription: "MyApp needs access to your health data to display workout metrics."
      NSHealthUpdateUsageDescription: "MyApp needs to save workout data to Health."
  entitlements:
    path: MyAppWatch/MyAppWatch.entitlements
    properties:
      com.apple.developer.healthkit: true
      com.apple.developer.healthkit.access: []
  settings:
    base:
      PRODUCT_BUNDLE_IDENTIFIER: com.company.myapp.watchkitapp
      MARKETING_VERSION: 1.0.0
      CURRENT_PROJECT_VERSION: 1
      SWIFT_VERSION: 6.0
      GENERATE_INFOPLIST_FILE: false
  dependencies:
    - package: SharedModels
```

#### WidgetKit Extension (complete example)

```yaml
MyAppWidget:
  type: extensionkit-extension # Modern (Xcode 15+). Alternative: app-extension (has known device install issues)
  platform: iOS
  deploymentTarget: "18.0"
  sources:
    - path: MyAppWidget
  info:
    path: MyAppWidget/Info.plist
    properties:
      CFBundleVersion: $(CURRENT_PROJECT_VERSION)
      CFBundleShortVersionString: $(MARKETING_VERSION)
      NSExtension:
        NSExtensionPointIdentifier: com.apple.widgetkit-extension
      EXAppExtensionAttributes: # Required for extensionkit-extension type
        EXExtensionPointIdentifier: com.apple.widgetkit-extension
  entitlements:
    path: MyAppWidget/MyAppWidget.entitlements
    properties:
      com.apple.security.application-groups:
        - group.com.company.myapp
  settings:
    base:
      PRODUCT_BUNDLE_IDENTIFIER: com.company.myapp.widget
      MARKETING_VERSION: 1.0.0
      CURRENT_PROJECT_VERSION: 1
      GENERATE_INFOPLIST_FILE: false
  dependencies:
    - target: MyApp
      embed: false
    - package: SharedModels
```

### Common XcodeGen Pitfalls

| Mistake                                                            | Error / Symptom                                                   | Fix                                                                                                                                           |
| ------------------------------------------------------------------ | ----------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `entitlements` block without `path`                                | `Decoding failed at 'path': Nothing found`                        | Always include both `path` and `properties`                                                                                                   |
| Missing `.entitlements` file on disk                               | Build error: file not found                                       | Create the file (can be empty plist `<dict/>`) at the declared path                                                                           |
| Minimal Info.plist for watchOS (only `WKApplication: true`)        | Missing standard keys after build; Xcode warnings                 | Use the full seed plist template from this doc                                                                                                |
| Setting `GENERATE_INFOPLIST_FILE: true` with a custom `info.path`  | Conflicting Info.plist sources                                    | Set `GENERATE_INFOPLIST_FILE: false` when providing a custom `info.path`                                                                      |
| Extension bundle ID not prefixed with main app bundle ID           | Code signing / provisioning errors                                | Extension IDs MUST start with `${MAIN_BUNDLE_ID}.` (e.g., `.widget`, `.watchkitapp`)                                                          |
| Using `embed: true` for extension dependency on main app           | Incorrect embedding                                               | Extensions use `embed: false` for the main app target dependency                                                                              |
| Importing a module that depends on CombineRIBs/UIKit in watchOS    | Compile errors: missing module / UIKit unavailable                | Only import platform-agnostic modules. See module compatibility table in [ios-extensions-and-companions.md](ios-extensions-and-companions.md) |
| Shared module Package.swift missing `.watchOS(...)` platform       | watchOS target can't resolve the dependency                       | Add `.watchOS(.v10)` (or appropriate version) to the `platforms:` array                                                                       |
| Missing `WKCompanionAppBundleIdentifier` in watchOS Info.plist     | Watch app won't pair with iPhone app                              | Add the main app's bundle ID as `WKCompanionAppBundleIdentifier` in Info.plist                                                                |
| Missing `WKBackgroundModes` for workout sessions                   | Workout pauses when screen turns off                              | Add `workout-processing` to `WKBackgroundModes` in Info.plist                                                                                 |
| Missing HealthKit usage descriptions in Info.plist                 | Runtime crash on HealthKit access                                 | Add both `NSHealthShareUsageDescription` and `NSHealthUpdateUsageDescription`                                                                 |
| Using `supportedDestinations: [watchOS]` for a watchOS app target  | `Embed Watch Content` phase silently missing; app doesn't install | Use `platform: watchOS` instead. XcodeGen rejects `supportedDestinations` for watchOS app targets.                                            |
| Using `application.watchapp2` with Xcode 14+ single-target watchOS | "Multiple commands produce..." build error                        | Use `type: application` with `platform: watchOS` for modern single-target watchOS apps                                                        |
| Using `app-extension` for WidgetKit with Xcode 15+                 | Widget may fail to install on device (error `-402653081`)         | Use `type: extensionkit-extension` instead (modern ExtensionKit embedding)                                                                    |
| Missing `WKRunsIndependentlyOfCompanionApp` in watchOS Info.plist  | Watch app may not launch independently                            | Add `WKRunsIndependentlyOfCompanionApp: true` to Info.plist for independent watch apps                                                        |

### Build Schemes and Companion App Linking

XcodeGen auto-creates a build scheme for each target declared in `xcodegen.yml`. For watchOS companion apps:

- The watchOS target gets its own scheme automatically (e.g., "MyAppWatch").
- To run the watchOS app in the simulator, select the "MyAppWatch" scheme and an Apple Watch simulator destination.
- **Companion app linking** is handled via `WKCompanionAppBundleIdentifier` in the watchOS app's Info.plist — XcodeGen does NOT automatically link the targets. You must ensure the bundle ID matches the main app's `PRODUCT_BUNDLE_IDENTIFIER`.
- The watchOS app and iOS app are separate targets that share code only through SPM modules — they do not share source files or build settings.

### Shared SPM Package References

When both the main app and extension targets depend on the same SPM module, declare it once in the top-level `packages:` block:

```yaml
packages:
  IOS_APP_NAMEMain:
    path: ../Libraries/IOS_APP_NAMEMain
  SharedModels:
    path: ../Libraries/SharedModels

targets:
  MyApp:
    dependencies:
      - package: IOS_APP_NAMEMain # Main app RIBs
      - package: SharedModels # Shared with extensions

  MyAppWatch:
    type: application
    platform: watchOS
    dependencies:
      - package: SharedModels # Same shared module
```

**Important**: The shared module's `Package.swift` MUST declare all platforms it needs to support (e.g., `.iOS(.v16), .watchOS(.v10)`). If it only declares `.iOS(...)`, watchOS targets will fail to resolve the dependency.
