// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import UIKit
import SimpleTheming
import SwiftUI

public enum SemanticColor: ColorAssetable {

  // MARK: - Labels

  case labelPrimary
  case labelSecondary
  case labelTertiary
  case labelDisabled
  case labelInverse
  case labelLink
  case labelLinkPressed

  // MARK: - Backgrounds

  case backgroundPrimary
  case backgroundSecondary
  case backgroundTertiary
  case backgroundPrimaryElevated
  case backgroundSecondaryElevated
  case backgroundTertiaryElevated

  // MARK: - Backgrounds Grouped

  case backgroundGroupedPrimary
  case backgroundGroupedSecondary
  case backgroundGroupedTertiary
  case backgroundGroupedPrimaryElevated
  case backgroundGroupedSecondaryElevated
  case backgroundGroupedTertiaryElevated

  // MARK: - Overlay

  case overlayDefault
  case overlayActivityView

  // MARK: - Separators

  case separatorNonOpaque
  case separatorOpaque
  case separatorVibrant

  // MARK: - Fills

  case fillPrimary
  case fillSecondary
  case fillTertiary
  case fillQuaternary

  // MARK: - Interactive: Primary

  case interactivePrimary
  case interactivePrimaryPressed
  case interactivePrimaryDisabled

  // MARK: - Interactive: Secondary

  case interactiveSecondary
  case interactiveSecondaryPressed
  case interactiveSecondaryDisabled
  case interactiveSecondaryLabel
  case interactiveSecondaryDisabledLabel

  // MARK: - Interactive: Destructive

  case interactiveDestructive
  case interactiveDestructivePressed
  case interactiveDestructiveDisabled
  case interactiveDestructiveLabel
  case interactiveDestructiveDisabledLabel

  // MARK: - Interactive: Destructive Secondary

  case interactiveDestructiveSecondary
  case interactiveDestructiveSecondaryPressed
  case interactiveDestructiveSecondaryDisabled
  case interactiveDestructiveSecondaryLabel
  case interactiveDestructiveSecondaryDisabledLabel

  // MARK: - Interactive: Secondary Accent

  case interactiveSecondaryAccent
  case interactiveSecondaryAccentPressed
  case interactiveSecondaryAccentDisabled
  case interactiveSecondaryAccentLabel
  case interactiveSecondaryAccentDisabledLabel

  // MARK: - Interactive: Tertiary

  case interactiveTertiaryLabel
  case interactiveTertiaryPressed
  case interactiveTertiaryDisabledLabel

  // MARK: - Interactive: Tertiary Destructive

  case interactiveTertiaryDestructiveLabel
  case interactiveTertiaryDestructivePressed
  case interactiveTertiaryDestructiveDisabledLabel

  // MARK: - Interactive: Selection

  case interactiveSelected

  // MARK: - Feedback

  case feedbackSuccess
  case feedbackSuccessBg
  case feedbackWarning
  case feedbackWarningBg
  case feedbackError
  case feedbackErrorBg
  case feedbackInfo
  case feedbackInfoBg
  case feedbackInformation
  case feedbackInformationBg

  // MARK: - Form Controls

  case formInputBg
  case formInputText
  case formInputBorderFocused
  case formInputBorderError
  case formPlaceholder
  case formCursor
  case formSelectionBg
  case formToggleOff
  case formToggleOn
  case formToggleThumb
  case formCheckboxOff
  case formCheckboxOn

  // MARK: - Navigation

  case navBarBg

  // MARK: - Avatar

  case avatar1
  case avatar2
  case avatar3
  case avatar4
  case avatar5
  case avatar6
  case avatar7
  case avatar8
  case avatarText
  case avatarTextDark

  // MARK: - Progress & Rating

  case progressTrack
  case progressFill
  case progressSuccess
  case ratingFilled
  case ratingEmpty
  case sliderThumb
  case sliderTrack
  case sliderFill

  // MARK: - Presence

  case presenceOnline
  case presenceAway
  case presenceBusy
  case presenceOffline

  // MARK: - Badges

  case badgeDefault
  case badgeText

  // MARK: - Tags

  case tagDefault
  case tagDefaultText

  // MARK: - Chips

  case chipDefault
  case chipDefaultText
  case chipSelected
  case chipSelectedText

  // MARK: - Skeleton

  case skeletonBase
  case skeletonHighlight

  // MARK: - Icon Tiles

  case iconTileBackground
  case iconTileIcon

  // MARK: - Charts: Diverging

  case chartDivergingNegative
  case chartDivergingNeutral
  case chartDivergingPositive

  // MARK: - Charts: Sequential

  case chartSequential1
  case chartSequential2
  case chartSequential3
  case chartSequential4
  case chartSequential5

  // MARK: - Charts: Categorical

  case chartCategorical1
  case chartCategorical2
  case chartCategorical3
  case chartCategorical4
  case chartCategorical5
  case chartCategorical6
}

public extension ThemeProviding {
  func semanticColor(_ semanticColor: SemanticColor, preferredAppearance: PreferredAppearance? = nil, on theme: Theme? = nil) -> UIColor {

    return self.color(for: semanticColor, preferredAppearance: preferredAppearance, on: theme)
  }

  func color(_ semanticColor: SemanticColor, preferredAppearance: PreferredAppearance? = nil, on theme: Theme? = nil) -> Color {

    return Color(self.color(for: semanticColor, preferredAppearance: preferredAppearance, on: theme))
  }
}
