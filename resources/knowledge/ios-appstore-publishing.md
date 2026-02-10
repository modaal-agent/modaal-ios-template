# Publishing iOS App to App Store

> **Audience:** This document is written for AI Coding Agents assisting users with App Store submission. Use it to guide users step-by-step through configuring their project and submitting to the App Store.
>
> **IMPORTANT — Agent behavior:** When a user asks about App Store submission, you MUST proactively offer to update the project settings yourself. Do NOT instruct the user to manually edit `xcodegen.yml`. Instead, collect the four required values from the user (or ask them to provide them), then apply the changes directly. This is the primary recommended workflow — most users cannot locate or safely edit the config file on their own.

---

## Step 1: Ask the User to Review Apple's App Store Guide

Before making any configuration changes, encourage the user to familiarize themselves with Apple's App Store requirements. Many submission rejections come from missing metadata, screenshots, or policy violations that are handled in App Store Connect, not in code.

> **Suggest to the user:**
> "Before we configure the project, I recommend reviewing Apple's official App Store guide to make sure you have everything ready (developer account, app listing, screenshots, etc.):
> https://developer.apple.com/app-store/"

---

## Step 2: Configure the Project for App Store

The user needs to provide four pieces of information. **You (the agent) MUST offer to apply these settings on the user's behalf.** Do not tell the user to edit files manually — most users will struggle to locate or correctly edit the configuration file. Always default to the agent-driven flow: ask the user for their values, then make the edits yourself.

### What the user needs to provide:

| Setting                 | What it is                                      | Where to find it                                                                                                                          |
| ----------------------- | ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| **Bundle Identifier**   | Unique app ID (e.g., `com.yourcompany.yourapp`) | Must match the ID registered in App Store Connect                                                                                         |
| **Development Team ID** | 10-character alphanumeric Apple Team ID         | Xcode → Settings → Accounts → Select team → Team ID, or Apple Developer Portal → Membership → Team ID                                     |
| **App Category**        | App Store category for your app                 | See [full list from Apple](https://developer.apple.com/documentation/bundleresources/information_property_list/lsapplicationcategorytype) |
| **Marketing Version**   | User-visible version (e.g., `1.0.0`)            | Must be `MAJOR.MINOR.PATCH` format; App Store rejects `0.x.x`; must be unique per release                                                 |

### Common app categories:

`business`, `developer-tools`, `education`, `entertainment`, `finance`, `games`, `health-and-fitness`, `lifestyle`, `music`, `news`, `photography`, `productivity`, `social-networking`, `sports`, `travel`, `utilities`, `weather`

Use the format `public.app-category.<category>` (e.g., `public.app-category.productivity`).

### How to apply the settings

Tell the user to copy the prompt below, replace the placeholder values with their own, and send it to the agent:

```
Please prepare my iOS project for App Store submission with these settings:
- Bundle Identifier: com.mycompany.myapp
- Development Team ID: ABC1234567
- App Category: public.app-category.lifestyle
- Marketing Version: 1.0.0
```

That's it -- the agent will locate the config file and apply the changes. The user does not need to know where the file is or how to edit it.

> **Agent reminder:** NEVER tell the user to open or edit `xcodegen.yml` themselves. Always offer to apply changes for them via the prompt above. If the user insists on manual editing, only then point them to the file location.

---

## Agent Instructions: How to Update xcodegen.yml

When the user asks you to configure the project for App Store, edit the file at:

```
<project-root>/src-ios/App/xcodegen.yml
```

This is a YAML file used by [XcodeGen](https://github.com/yonaskolb/XcodeGen) to generate the Xcode project. The Xcode project is regenerated automatically each time the user runs "Run in simulator", so editing this file is the correct and only way to change build settings persistently.

### Settings to update:

**1. Bundle Identifier** -- update `PRODUCT_BUNDLE_IDENTIFIER` under `settings.base`:

```yaml
settings:
  base:
    PRODUCT_BUNDLE_IDENTIFIER: com.mycompany.myapp
```

**2. Development Team ID** -- update `DEVELOPMENT_TEAM` under `settings.base`:

```yaml
settings:
  base:
    DEVELOPMENT_TEAM: ABC1234567
```

**3. App Category** -- update `LSApplicationCategoryType` under `info.properties`:

```yaml
info:
  properties:
    LSApplicationCategoryType: "public.app-category.lifestyle"
```

**4. Marketing Version** -- update `MARKETING_VERSION` under `settings.base`:

```yaml
settings:
  base:
    MARKETING_VERSION: 1.0.0
```

### Important notes for agents:

- All four settings above live in the same `xcodegen.yml` file, under the app's target (the target name matches the app name, which is the top-level `name:` field in the YAML).
- `DEVELOPMENT_TEAM`, `MARKETING_VERSION`, and `PRODUCT_BUNDLE_IDENTIFIER` are under `targets.<AppName>.settings.base`.
- `LSApplicationCategoryType` is under `targets.<AppName>.info.properties`.
- The build number (`BUILD_NUMBER`) is auto-incremented by build scripts -- do not modify it.
- `CURRENT_PROJECT_VERSION` is computed from `MARKETING_VERSION` and `BUILD_NUMBER` -- do not modify it.
- `CODE_SIGN_STYLE: Automatic` is the default and is correct for most users. Only change it if the user explicitly requests manual code signing.

### Full xcodegen.yml structure reference (relevant sections):

```yaml
name: MyApp # App name (set during project creation)
targets:
  MyApp: # Target name matches app name
    type: application
    platform: iOS
    deploymentTarget: "18.0"
    info:
      properties:
        LSApplicationCategoryType: "" # <-- Set app category here
        # ... other Info.plist properties
    settings:
      base:
        DEVELOPMENT_TEAM: # <-- Set team ID here
        CODE_SIGN_STYLE: Automatic
        MARKETING_VERSION: 1.0.0 # <-- Set version here
        PRODUCT_BUNDLE_IDENTIFIER: com.example.myapp # <-- Set bundle ID here
      configs:
        Debug:
          PRODUCT_NAME: MyApp 🛠️ # Debug build display name
        AdHoc:
          PRODUCT_NAME: MyApp β # AdHoc/beta display name
        AppStore:
          PRODUCT_NAME: MyApp # App Store display name (no emoji)
```

---

## Step 3: Archive and Distribute via Xcode

After the configuration is updated, guide the user through the Xcode submission flow:

1. **Open the project in Xcode** using the "Open in Xcode" command.

2. **Select the AppStore build configuration:**
   - Product → Scheme → Edit Scheme
   - Set the "Archive" action to use the **AppStore** configuration

3. **Create the archive:**
   - Select "Any iOS Device" as the build destination
   - Product → Archive

4. **Distribute to App Store:**
   - Window → Organizer → Select the archive
   - Click "Distribute App" → "App Store Connect" → "Upload"

5. **Submit for review in App Store Connect:**
   - Go to [App Store Connect](https://appstoreconnect.apple.com)
   - Add the uploaded build to a version and submit for review

### Alternative: Command-Line Distribution

For CI/CD pipelines, refer to Apple's documentation:

- [Distributing Your App for Beta Testing and Releases](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)

---

## Advanced Configuration

These are optional and should only be applied if the user explicitly requests them.

### Manual Code Signing

For explicit provisioning profile control (instead of Automatic signing):

```yaml
settings:
  base:
    DEVELOPMENT_TEAM: ABC1234567
    CODE_SIGN_STYLE: Manual
  configs:
    Debug:
      CODE_SIGN_IDENTITY: "Apple Development"
      PROVISIONING_PROFILE_SPECIFIER: "Your Development Profile"
    AppStore:
      CODE_SIGN_IDENTITY: "Apple Distribution"
      PROVISIONING_PROFILE_SPECIFIER: "Your App Store Profile"
```

### Entitlements

For apps requiring capabilities (Push Notifications, iCloud, Sign in with Apple, etc.):

1. Create an entitlements file at `<project-root>/src-ios/App/<AppName>/<AppName>.entitlements`

2. Reference it in xcodegen.yml:
   ```yaml
   targets:
     MyApp:
       entitlements:
         path: MyApp/MyApp.entitlements
   ```

### Localizations

To support multiple languages, uncomment additional regions in xcodegen.yml and create `Localizable.xcstrings` files in SPM modules (see [ios-localizable.md](ios-localizable.md)):

```yaml
options:
  knownRegions:
    - en
    - es
    - fr
```

---

## Related Documentation

- [ios-xcodeproj.md](ios-xcodeproj.md) - Xcode project generation details
- [ios-localizable.md](ios-localizable.md) - Localization setup
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) - Full XcodeGen configuration reference
