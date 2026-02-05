# iOS Design System

## Liquid Glass and iOS 26 Design Language

When designing SwiftUI views, unless strictly instructed by the user, target the iOS 26 SDK and align UI decisions with Apple's new iOS 26 design built around Liquid Glass. ￼
Prefer system components first (standard buttons, lists, forms, navigation, sheets) so your UI inherits Liquid Glass behavior automatically, instead of recreating "glassy" chrome manually. ￼
Use navigation patterns that match the new design (e.g., NavigationStack + toolbar, updated tab bars/sidebars) and keep content feeling spacious, layered, and responsive rather than boxed-in. ￼
For common surfaces (search/filter bars, floating actions, popovers, headers), favor Liquid Glass materials/modifiers over hand-rolled blur overlays, and test in light/dark and different appearance modes to ensure legibility. ￼
Example: if you need a "glass card," build it from a native container style/material + system shadows and spacing, not a custom gradient + blur stack. ￼
Use SF Symbols and consistent system sizing/hit targets so icons, controls, and motion feel like first-party iOS 26 rather than a bespoke theme. ￼
If the user targets iOS 18 or earlier, guard iOS 26-only APIs with `@available(iOS 26, *)` and provide fallbacks that preserve layout and behavior (not just visual parity). ￼
When in doubt, sanity-check screen composition against Apple's Liquid Glass redesign examples (home, detail, search, settings) and bias toward "Apple-like" defaults over novelty. ￼

## Typography: Semantic Font Name

Only use following semantic font names when designing views in SwiftUI.

```swift
/// Semantic typography scale used across the app.
///
/// These cases map to concrete fonts + metrics in the design system
/// and should be chosen based on hierarchy and context, not raw size.
public enum SemanticFont: FontAssetable {
  /// Primary large navigation title for top-level screens, onboarding, paywalls, and hero surfaces. Represents the highest hierarchy and collapses into an inline title when scrolling.
  case largeTitle

  /// Primary content heading (H1) below the nav. Used for main sections, hero intros, and prominent content groups inside a screen.
  case title1
  /// Secondary section heading (H2) for subsections, grouped content, dashboards, and structured flows where hierarchy must still be strong.
  case title2
  /// Compact tertiary heading (H3). Used where you need clear hierarchy for cards, list group titles, tiles, or inline section labels but have limited space.
  case title3

  /// High-emphasis inline title for collapsed navigation bars, key values, and strong content titles inside cards or sections. Used for inline UI titles, not for content section headers.
  case headline

  /// Default body text for paragraphs, list rows, settings, descriptions, and general content. Base reading style for most UI surfaces.
  case bodyRegular
  /// Medium-emphasis body text for selected or active values and for inline emphasis where weight alone communicates importance. Not used for structural labels or titles.
  case bodyMedium
  /// Strongly emphasized body-size text for short, critical inline messages (e.g. confirmations, key numbers in a sentence, short alerts) where you need maximum emphasis at body scale without switching to a heading.
  case bodyEmphasized

  /// Highlighted reading text between body and subhead. Used for short statements, section intros, and important explanations that should stand out from regular body text without becoming a heading or label.
  case calloutRegular
  /// Strongly highlighted callout text for critical standalone statements inside content. Used for key benefits, important notices, or short, high-impact messages that must be more prominent than body text but do not warrant a title.
  case calloutEmphasized

  /// Secondary supporting text one step below body. Used for subtitles under headings, secondary labels closely attached to primary labels, and helper text that still needs to be easily readable.
  case subheadRegular
  /// Medium-emphasis small subhead for highlighted subtitles, secondary labels, and inline text that must stand out slightly more than regular supporting copy.
  case subheadMedium
  /// High-emphasis small title for compact layouts. Used for short section titles, group labels, and other small headings where space is tight but hierarchy must be very clear.
  case subheadEmphasized

  /// Small, low-priority text for metadata, timestamps, secondary labels, and quiet supporting information not tightly bound to a specific UI element
  case footnoteRegular
  /// Medium-emphasis small text for highlighted metadata, secondary labels, and compact UI elements that need clearer visibility than regular footnote.
  case footnoteMedium
  /// High-emphasis micro text for compact UI where a small but strong hierarchy is required—status indicators, small badges, or mini section headings in dense layouts.
  case footnoteEmphasized

  /// Tiniest comfortable text for timestamps, auxiliary metadata, and compact UI details where space is limited. Best for quiet, non-interactive micro-information.
  case caption1Regular
  /// Medium-emphasis microtext for highlighted micro-labels, counters, and small badges that must remain readable at very small sizes.
  case caption1Emphasized

  /// Extra-small text for ultra-dense layouts, fine-print metadata, and subtle supporting details where space is extremely limited and content is rarely primary.
  case caption2Regular
  /// Emphasized extra-small text for tiny badges, compact status labels, and other UI indicators that must stay legible despite minimal size and lowest scale.
  case caption2Emphasized
}
```

## Semantic Colors

Only use following semantic color names when designing views in SwiftUI. All colors support light and dark mode automatically via `ThemeProvider`.

```swift
public enum SemanticColor: ColorAssetable {

  // MARK: - Labels
  case labelPrimary          // Main body text, headlines, toolbar/list icons
  case labelSecondary        // Supporting text, descriptions, captions
  case labelTertiary         // Placeholders, hints, chevrons, inactive tabs
  case labelDisabled         // Disabled labels and icons
  case labelInverse          // White text/icons on colored backgrounds
  case labelLink             // Tappable links, hyperlinks
  case labelLinkPressed      // Link pressed state

  // MARK: - Backgrounds
  case backgroundPrimary           // Base canvas (feeds, articles, plain lists)
  case backgroundSecondary         // Subtle layering, dashboard/info cards
  case backgroundTertiary          // Content on secondary that needs to pop
  case backgroundPrimaryElevated   // Modal sheets, alerts, popovers
  case backgroundSecondaryElevated // Grouped sections within modals
  case backgroundTertiaryElevated  // Inputs inside elevated secondary areas

  // MARK: - Backgrounds Grouped
  case backgroundGroupedPrimary           // Canvas behind grouped lists (Settings-style)
  case backgroundGroupedSecondary         // Individual cells/rows in grouped lists
  case backgroundGroupedTertiary          // Sub-sections within cells
  case backgroundGroupedPrimaryElevated   // Grouped lists inside modals
  case backgroundGroupedSecondaryElevated // Cells within modal grouped lists
  case backgroundGroupedTertiaryElevated  // Sub-sections within modal cells

  // MARK: - Overlay
  case overlayDefault        // Modal sheets, alerts, context menus scrim
  case overlayActivityView   // Share sheet overlay only

  // MARK: - Separators
  case separatorNonOpaque    // Most common: list cell separators, dividers
  case separatorOpaque       // Full-width hard dividers, section breaks
  case separatorVibrant      // Separators on blurred/translucent surfaces

  // MARK: - Fills
  case fillPrimary           // Search bars, segmented controls, text fields
  case fillSecondary         // Steppers, date pickers, secondary buttons
  case fillTertiary          // Tab bar backgrounds, context menus
  case fillQuaternary        // Large area subtle backgrounds, disabled fills

  // MARK: - Interactive: Primary
  case interactivePrimary         // Primary button bg, active tab, toggle on
  case interactivePrimaryPressed  // Pressed state
  case interactivePrimaryDisabled // Disabled state

  // MARK: - Interactive: Secondary
  case interactiveSecondary              // Secondary button bg
  case interactiveSecondaryPressed       // Pressed state
  case interactiveSecondaryDisabled      // Disabled bg
  case interactiveSecondaryLabel         // Button label
  case interactiveSecondaryDisabledLabel // Disabled label

  // MARK: - Interactive: Destructive
  case interactiveDestructive              // Destructive button bg, alert destructive text
  case interactiveDestructivePressed       // Pressed state
  case interactiveDestructiveDisabled      // Disabled bg
  case interactiveDestructiveLabel         // Button label (white)
  case interactiveDestructiveDisabledLabel // Disabled label

  // MARK: - Interactive: Destructive Secondary
  case interactiveDestructiveSecondary              // Secondary destructive bg
  case interactiveDestructiveSecondaryPressed       // Pressed state
  case interactiveDestructiveSecondaryDisabled      // Disabled bg
  case interactiveDestructiveSecondaryLabel         // Button label
  case interactiveDestructiveSecondaryDisabledLabel // Disabled label

  // MARK: - Interactive: Secondary Accent
  case interactiveSecondaryAccent              // Promotional cards, secondary CTA
  case interactiveSecondaryAccentPressed       // Pressed state
  case interactiveSecondaryAccentDisabled      // Disabled bg
  case interactiveSecondaryAccentLabel         // Label (white)
  case interactiveSecondaryAccentDisabledLabel // Disabled label

  // MARK: - Interactive: Tertiary
  case interactiveTertiaryLabel         // Text-only button (green text, no bg)
  case interactiveTertiaryPressed       // Subtle highlight on tap
  case interactiveTertiaryDisabledLabel // Disabled text

  // MARK: - Interactive: Tertiary Destructive
  case interactiveTertiaryDestructiveLabel         // Red text-only button
  case interactiveTertiaryDestructivePressed       // Subtle red highlight on tap
  case interactiveTertiaryDestructiveDisabledLabel // Disabled text

  // MARK: - Interactive: Selection
  case interactiveSelected   // Persistent selection bg (selected rows, pickers)

  // MARK: - Feedback
  case feedbackSuccess        // Success text and status icons
  case feedbackSuccessBg      // Success banner background
  case feedbackWarning        // Warning text and status icons
  case feedbackWarningBg      // Warning banner background
  case feedbackError          // Error text and status icons
  case feedbackErrorBg        // Error banner background
  case feedbackInfo           // Special/premium text (Beta, Preview badges)
  case feedbackInfoBg         // Special/premium banner background
  case feedbackInformation    // Neutral info text (Help, Tip badges)
  case feedbackInformationBg  // Neutral info banner background

  // MARK: - Form Controls
  case formInputBg            // Input background (filled style)
  case formInputText          // Text color inside inputs
  case formInputBorderFocused // Focused border
  case formInputBorderError   // Error border
  case formPlaceholder        // Placeholder text
  case formCursor             // Text cursor
  case formSelectionBg        // Text selection highlight
  case formToggleOff          // Toggle off track
  case formToggleOn           // Toggle on track
  case formToggleThumb        // Toggle thumb (white)
  case formCheckboxOff        // Unchecked checkbox
  case formCheckboxOn         // Checked checkbox

  // MARK: - Navigation
  case navBarBg               // Translucent nav/tab bar background (85% opacity)

  // MARK: - Avatar
  case avatar1 ... avatar8   // 8 avatar background colors
  case avatarText             // Text on dark avatar backgrounds (white)
  case avatarTextDark         // Text on light avatar backgrounds (dark)

  // MARK: - Progress & Rating
  case progressTrack          // Progress bar track
  case progressFill           // Progress bar fill
  case progressSuccess        // Completed progress
  case ratingFilled           // Filled star
  case ratingEmpty            // Empty star
  case sliderThumb            // Slider thumb (white)
  case sliderTrack            // Slider track
  case sliderFill             // Slider fill

  // MARK: - Presence
  case presenceOnline         // Online status (green)
  case presenceAway           // Away status (yellow)
  case presenceBusy           // Busy/DND status (red)
  case presenceOffline        // Offline status (gray)

  // MARK: - Badges
  case badgeDefault           // Red notification badge
  case badgeText              // Badge text (white)

  // MARK: - Tags
  case tagDefault             // Static tag background
  case tagDefaultText         // Tag text

  // MARK: - Chips
  case chipDefault            // Unselected filter chip bg
  case chipDefaultText        // Unselected chip text
  case chipSelected           // Selected filter chip bg (green tint)
  case chipSelectedText       // Selected chip text

  // MARK: - Skeleton
  case skeletonBase           // Loading skeleton placeholder
  case skeletonHighlight      // Shimmer highlight gradient

  // MARK: - Icon Tiles
  case iconTileBackground     // Settings-style icon tile bg
  case iconTileIcon           // Icon glyph on tile

  // MARK: - Charts: Diverging
  case chartDivergingNegative // Below baseline (red)
  case chartDivergingNeutral  // Near baseline (gray)
  case chartDivergingPositive // Above baseline (cyan)

  // MARK: - Charts: Sequential
  case chartSequential1 ... chartSequential5  // Low → High intensity ramp (pink)

  // MARK: - Charts: Categorical
  case chartCategorical1 ... chartCategorical6  // 6 fixed series colors
}
```

### Color Token Quick Reference

| Purpose               | Token                                                           |
| --------------------- | --------------------------------------------------------------- |
| Main text             | `.labelPrimary`                                                 |
| Secondary text        | `.labelSecondary`                                               |
| Hints/placeholders    | `.labelTertiary`                                                |
| Tappable links        | `.labelLink`                                                    |
| Primary button bg     | `.interactivePrimary` + `.labelInverse` text                    |
| Secondary button bg   | `.interactiveSecondary` + `.interactiveSecondaryLabel` text     |
| Destructive button bg | `.interactiveDestructive` + `.interactiveDestructiveLabel` text |
| Text-only CTA         | `.interactiveTertiaryLabel` (no bg)                             |
| Text-only destructive | `.interactiveTertiaryDestructiveLabel` (no bg)                  |
| Accent card/banner    | `.interactiveSecondaryAccent` + `.labelInverse` text            |
| Success feedback      | `.feedbackSuccess` / `.feedbackSuccessBg`                       |
| Warning feedback      | `.feedbackWarning` / `.feedbackWarningBg`                       |
| Error feedback        | `.feedbackError` / `.feedbackErrorBg`                           |
| Info feedback         | `.feedbackInformation` / `.feedbackInformationBg`               |
| Toggle on             | `.formToggleOn`                                                 |
| Active tab            | `.interactivePrimary`                                           |
| Inactive tab          | `.labelTertiary`                                                |
| Dashboard cards       | `.backgroundSecondary`                                          |
| Settings rows         | `.backgroundGroupedSecondary` on `.backgroundGroupedPrimary`    |
| Modal bg              | `.backgroundPrimaryElevated`                                    |

### Background Selection Guide

| Screen Type                         | Background Token                                                               |
| ----------------------------------- | ------------------------------------------------------------------------------ |
| Scrolling content (feeds, articles) | `.backgroundPrimary`                                                           |
| Settings-style grouped lists        | `.backgroundGroupedPrimary` for screen, `.backgroundGroupedSecondary` for rows |
| Modal sheets                        | `.backgroundPrimaryElevated` or `.backgroundGroupedPrimaryElevated`            |
| Dashboard/info cards                | `.backgroundSecondary`                                                         |

### Button Style Guide

| Button Style                         | Background                         | Label                                   | Pressed                                   | Disabled bg                                | Disabled label                                  |
| ------------------------------------ | ---------------------------------- | --------------------------------------- | ----------------------------------------- | ------------------------------------------ | ----------------------------------------------- |
| **Primary**                          | `.interactivePrimary`              | `.labelInverse`                         | `.interactivePrimaryPressed`              | `.interactivePrimaryDisabled`              | `.labelDisabled`                                |
| **Secondary**                        | `.interactiveSecondary`            | `.interactiveSecondaryLabel`            | `.interactiveSecondaryPressed`            | `.interactiveSecondaryDisabled`            | `.interactiveSecondaryDisabledLabel`            |
| **Destructive**                      | `.interactiveDestructive`          | `.interactiveDestructiveLabel`          | `.interactiveDestructivePressed`          | `.interactiveDestructiveDisabled`          | `.interactiveDestructiveDisabledLabel`          |
| **Destructive Secondary**            | `.interactiveDestructiveSecondary` | `.interactiveDestructiveSecondaryLabel` | `.interactiveDestructiveSecondaryPressed` | `.interactiveDestructiveSecondaryDisabled` | `.interactiveDestructiveSecondaryDisabledLabel` |
| **Secondary Accent**                 | `.interactiveSecondaryAccent`      | `.interactiveSecondaryAccentLabel`      | `.interactiveSecondaryAccentPressed`      | `.interactiveSecondaryAccentDisabled`      | `.interactiveSecondaryAccentDisabledLabel`      |
| **Tertiary** (text-only)             | none                               | `.interactiveTertiaryLabel`             | `.interactiveTertiaryPressed`             | none                                       | `.interactiveTertiaryDisabledLabel`             |
| **Tertiary Destructive** (text-only) | none                               | `.interactiveTertiaryDestructiveLabel`  | `.interactiveTertiaryDestructivePressed`  | none                                       | `.interactiveTertiaryDestructiveDisabledLabel`  |

### Icon Color Selection

| Icon Context                                 | Token                                                      |
| -------------------------------------------- | ---------------------------------------------------------- |
| Status indicator (checkmark, warning, error) | `.feedbackSuccess` / `.feedbackWarning` / `.feedbackError` |
| Inside filled button or colored bg           | `.labelInverse`                                            |
| Standalone primary action (FAB)              | `.interactivePrimary`                                      |
| Active tab                                   | `.interactivePrimary`                                      |
| Inactive tab                                 | `.labelTertiary`                                           |
| Toolbar/navbar button                        | `.labelPrimary`                                            |
| Chevron/disclosure                           | `.labelTertiary`                                           |
| Disabled icon                                | `.labelDisabled`                                           |
| On Settings icon tile                        | `.iconTileIcon` on `.iconTileBackground`                   |
| Default fallback                             | `.labelPrimary`                                            |

## How to use semantic fonts/colors in `UIView`'s ThemeProvider)

Theming module implements ThemeProvider, that can be used to provide semantic fonts and colors to SwiftUI views.
Inject an instance of `themeProvider: ThemeProviding` via DI chain.

Example (SplashView.swift):

```swift
import UIKit
import SwiftUI
import SimpleTheming
import Theming

final class SplashViewController: UIHostingController<SplashView>, SplashPresentable, ViewControllable {
  private let themeProvider: ThemeProviding

  init(themeProvider: ThemeProviding) {
    self.themeProvider = themeProvider
    self.viewState = SplashViewState()
    super.init(rootView: SplashView(themeProvider: themeProvider, viewState: viewState))
  }
}

class SplashViewState: ObservableObject {
  @Published var localizedLogoSubtitle: LocalizedStringResource?
}

struct SplashView: View {
  private let themeProvider: ThemeProviding
  @ObservedObject private var viewState: SplashViewState

  init(themeProvider: ThemeProviding, viewState: SplashViewState) {
    self.themeProvider = themeProvider
    self._viewState = ObservedObject(wrappedValue: viewState)
  }

  var body: some View {
    ZStack {
      themeProvider.color(.backgroundPrimary)
        .ignoresSafeArea()

      VStack(spacing: 20) {
        Text(localizable: .splashLogoSubtitle)
          .font(themeProvider.font(.largeTitle))
          .foregroundColor(themeProvider.color(.labelSecondary))
          .multilineTextAlignment(.center)

        if let localizedLogoSubtitle = viewState.localizedLogoSubtitle {
          Text(localizedLogoSubtitle)
            .font(themeProvider.font(.subheadMedium))
            .foregroundColor(themeProvider.color(.labelPrimary))
        }
      }
    }
  }
}
```
