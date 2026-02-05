// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import UIKit
import SimpleTheming
import SwiftUI

// MARK: - SemanticColor

extension MainTheme {
  public typealias _ColorAsset = SemanticColor

  public func colorSet(for asset: _ColorAsset) -> ColorSet {
    // Synced with color-tokens.md design system
    switch asset {

    // MARK: Labels

    case .labelPrimary:
      return ColorSet(.auto(light: UIColor(rgb: 0x131213), dark: UIColor(rgb: 0xF7F4F7)))
    case .labelSecondary:
      return ColorSet(.auto(light: UIColor(rgb: 0x131213, alpha: 0.6), dark: UIColor(rgb: 0xF7F4F7, alpha: 0.6)))
    case .labelTertiary:
      return ColorSet(.auto(light: UIColor(rgb: 0x131213, alpha: 0.3), dark: UIColor(rgb: 0xF6F3F6, alpha: 0.3)))
    case .labelDisabled:
      return ColorSet(.auto(light: UIColor(rgb: 0x131213, alpha: 0.3), dark: UIColor(rgb: 0xF6F3F6, alpha: 0.3)))
    case .labelInverse:
      return ColorSet(.static(UIColor(rgb: 0xFFFFFF)))
    case .labelLink:
      return ColorSet(.auto(light: UIColor(rgb: 0x94497D), dark: UIColor(rgb: 0xC562A6)))
    case .labelLinkPressed:
      return ColorSet(.auto(light: UIColor(rgb: 0x623153), dark: UIColor(rgb: 0xFBBEE5)))

    // MARK: Backgrounds

    case .backgroundPrimary:
      return ColorSet(.auto(light: UIColor(rgb: 0xFFFFFF), dark: UIColor(rgb: 0x000000)))
    case .backgroundSecondary:
      return ColorSet(.auto(light: UIColor(rgb: 0xF7F4F7), dark: UIColor(rgb: 0x1E1D1E)))
    case .backgroundTertiary:
      return ColorSet(.auto(light: UIColor(rgb: 0xFFFFFF), dark: UIColor(rgb: 0x2A292A)))
    case .backgroundPrimaryElevated:
      return ColorSet(.auto(light: UIColor(rgb: 0xFFFFFF), dark: UIColor(rgb: 0x1E1D1E)))
    case .backgroundSecondaryElevated:
      return ColorSet(.auto(light: UIColor(rgb: 0xF7F4F7), dark: UIColor(rgb: 0x2A292A)))
    case .backgroundTertiaryElevated:
      return ColorSet(.auto(light: UIColor(rgb: 0xFFFFFF), dark: UIColor(rgb: 0x3D3C3D)))

    // MARK: Backgrounds Grouped

    case .backgroundGroupedPrimary:
      return ColorSet(.auto(light: UIColor(rgb: 0xF7F4F7), dark: UIColor(rgb: 0x000000)))
    case .backgroundGroupedSecondary:
      return ColorSet(.auto(light: UIColor(rgb: 0xFFFFFF), dark: UIColor(rgb: 0x1E1D1E)))
    case .backgroundGroupedTertiary:
      return ColorSet(.auto(light: UIColor(rgb: 0xF7F4F7), dark: UIColor(rgb: 0x2A292A)))
    case .backgroundGroupedPrimaryElevated:
      return ColorSet(.auto(light: UIColor(rgb: 0xF7F4F7), dark: UIColor(rgb: 0x1E1D1E)))
    case .backgroundGroupedSecondaryElevated:
      return ColorSet(.auto(light: UIColor(rgb: 0xFFFFFF), dark: UIColor(rgb: 0x2A292A)))
    case .backgroundGroupedTertiaryElevated:
      return ColorSet(.auto(light: UIColor(rgb: 0xF7F4F7), dark: UIColor(rgb: 0x3D3C3D)))

    // MARK: Overlay

    case .overlayDefault:
      return ColorSet(.auto(light: UIColor(rgb: 0x000000, alpha: 0.2), dark: UIColor(rgb: 0x000000, alpha: 0.48)))
    case .overlayActivityView:
      return ColorSet(.auto(light: UIColor(rgb: 0x000000, alpha: 0.2), dark: UIColor(rgb: 0x000000, alpha: 0.29)))

    // MARK: Separators

    case .separatorNonOpaque:
      return ColorSet(.auto(light: UIColor(rgb: 0x131213, alpha: 0.12), dark: UIColor(rgb: 0xF7F4F7, alpha: 0.17)))
    case .separatorOpaque:
      return ColorSet(.auto(light: UIColor(rgb: 0xD6D3D6), dark: UIColor(rgb: 0x3D3C3D)))
    case .separatorVibrant:
      return ColorSet(.auto(light: UIColor(rgb: 0xE9E7E9), dark: UIColor(rgb: 0x1E1D1E)))

    // MARK: Fills

    case .fillPrimary:
      return ColorSet(.auto(light: UIColor(rgb: 0x7C787C, alpha: 0.20), dark: UIColor(rgb: 0x7C797C, alpha: 0.36)))
    case .fillSecondary:
      return ColorSet(.auto(light: UIColor(rgb: 0x7C787C, alpha: 0.16), dark: UIColor(rgb: 0x7C797C, alpha: 0.32)))
    case .fillTertiary:
      return ColorSet(.auto(light: UIColor(rgb: 0x7C787C, alpha: 0.12), dark: UIColor(rgb: 0x7C797C, alpha: 0.24)))
    case .fillQuaternary:
      return ColorSet(.auto(light: UIColor(rgb: 0x7C787C, alpha: 0.08), dark: UIColor(rgb: 0x7C797C, alpha: 0.18)))

    // MARK: Interactive: Primary

    case .interactivePrimary:
      return ColorSet(.auto(light: UIColor(rgb: 0x61734B), dark: UIColor(rgb: 0x7F9762)))
    case .interactivePrimaryPressed:
      return ColorSet(.auto(light: UIColor(rgb: 0x4E5C3C), dark: UIColor(rgb: 0x9EB46D)))
    case .interactivePrimaryDisabled:
      return ColorSet(.auto(light: UIColor(rgb: 0x61734B, alpha: 0.20), dark: UIColor(rgb: 0x7F9762, alpha: 0.20)))

    // MARK: Interactive: Secondary

    case .interactiveSecondary:
      return ColorSet(.auto(light: UIColor(rgb: 0x7C787C, alpha: 0.12), dark: UIColor(rgb: 0x7C797C, alpha: 0.24)))
    case .interactiveSecondaryPressed:
      return ColorSet(.auto(light: UIColor(rgb: 0x7C787C, alpha: 0.16), dark: UIColor(rgb: 0x7C797C, alpha: 0.28)))
    case .interactiveSecondaryDisabled:
      return ColorSet(.auto(light: UIColor(rgb: 0x7C787C, alpha: 0.12), dark: UIColor(rgb: 0x7C797C, alpha: 0.24)))
    case .interactiveSecondaryLabel:
      return ColorSet(.auto(light: UIColor(rgb: 0x131213), dark: UIColor(rgb: 0xF7F4F7)))
    case .interactiveSecondaryDisabledLabel:
      return ColorSet(.auto(light: UIColor(rgb: 0x131213, alpha: 0.30), dark: UIColor(rgb: 0xF7F4F7, alpha: 0.30)))

    // MARK: Interactive: Destructive

    case .interactiveDestructive:
      return ColorSet(.auto(light: UIColor(rgb: 0xC84B38), dark: UIColor(rgb: 0xE56757)))
    case .interactiveDestructivePressed:
      return ColorSet(.auto(light: UIColor(rgb: 0xA03C2D), dark: UIColor(rgb: 0xDC8078)))
    case .interactiveDestructiveDisabled:
      return ColorSet(.auto(light: UIColor(rgb: 0xC84B38, alpha: 0.20), dark: UIColor(rgb: 0xE56757, alpha: 0.20)))
    case .interactiveDestructiveLabel:
      return ColorSet(.static(UIColor(rgb: 0xFFFFFF)))
    case .interactiveDestructiveDisabledLabel:
      return ColorSet(.static(UIColor(rgb: 0xFFFFFF, alpha: 0.30)))

    // MARK: Interactive: Destructive Secondary

    case .interactiveDestructiveSecondary:
      return ColorSet(.auto(light: UIColor(rgb: 0xC84B38, alpha: 0.16), dark: UIColor(rgb: 0xE56757, alpha: 0.16)))
    case .interactiveDestructiveSecondaryPressed:
      return ColorSet(.auto(light: UIColor(rgb: 0xC84B38, alpha: 0.25), dark: UIColor(rgb: 0xE56757, alpha: 0.25)))
    case .interactiveDestructiveSecondaryDisabled:
      return ColorSet(.auto(light: UIColor(rgb: 0xC84B38, alpha: 0.16), dark: UIColor(rgb: 0xE56757, alpha: 0.16)))
    case .interactiveDestructiveSecondaryLabel:
      return ColorSet(.auto(light: UIColor(rgb: 0xC84B38), dark: UIColor(rgb: 0xE56757)))
    case .interactiveDestructiveSecondaryDisabledLabel:
      return ColorSet(.auto(light: UIColor(rgb: 0xC84B38, alpha: 0.30), dark: UIColor(rgb: 0xE56757, alpha: 0.30)))

    // MARK: Interactive: Secondary Accent

    case .interactiveSecondaryAccent:
      return ColorSet(.auto(light: UIColor(rgb: 0xF67AD0), dark: UIColor(rgb: 0xF88FD4)))
    case .interactiveSecondaryAccentPressed:
      return ColorSet(.auto(light: UIColor(rgb: 0xC562A6), dark: UIColor(rgb: 0xF9A5DB)))
    case .interactiveSecondaryAccentDisabled:
      return ColorSet(.auto(light: UIColor(rgb: 0xF67AD0, alpha: 0.20), dark: UIColor(rgb: 0xF88FD4, alpha: 0.20)))
    case .interactiveSecondaryAccentLabel:
      return ColorSet(.static(UIColor(rgb: 0xFFFFFF)))
    case .interactiveSecondaryAccentDisabledLabel:
      return ColorSet(.static(UIColor(rgb: 0xFFFFFF, alpha: 0.30)))

    // MARK: Interactive: Tertiary

    case .interactiveTertiaryLabel:
      return ColorSet(.auto(light: UIColor(rgb: 0x61734B), dark: UIColor(rgb: 0x7F9762)))
    case .interactiveTertiaryPressed:
      return ColorSet(.auto(light: UIColor(rgb: 0x61734B, alpha: 0.12), dark: UIColor(rgb: 0x7F9762, alpha: 0.16)))
    case .interactiveTertiaryDisabledLabel:
      return ColorSet(.auto(light: UIColor(rgb: 0x131213, alpha: 0.30), dark: UIColor(rgb: 0xF6F3F6, alpha: 0.30)))

    // MARK: Interactive: Tertiary Destructive

    case .interactiveTertiaryDestructiveLabel:
      return ColorSet(.auto(light: UIColor(rgb: 0xC84B38), dark: UIColor(rgb: 0xE56757)))
    case .interactiveTertiaryDestructivePressed:
      return ColorSet(.auto(light: UIColor(rgb: 0xC84B38, alpha: 0.12), dark: UIColor(rgb: 0xE56757, alpha: 0.16)))
    case .interactiveTertiaryDestructiveDisabledLabel:
      return ColorSet(.auto(light: UIColor(rgb: 0xC84B38, alpha: 0.30), dark: UIColor(rgb: 0xE56757, alpha: 0.30)))

    // MARK: Interactive: Selection

    case .interactiveSelected:
      return ColorSet(.auto(light: UIColor(rgb: 0x7C787C, alpha: 0.16), dark: UIColor(rgb: 0x7C797C, alpha: 0.24)))

    // MARK: Feedback

    case .feedbackSuccess:
      return ColorSet(.auto(light: UIColor(rgb: 0x4E5C3C), dark: UIColor(rgb: 0x9EB46D)))
    case .feedbackSuccessBg:
      return ColorSet(.auto(light: UIColor(rgb: 0x61734B, alpha: 0.12), dark: UIColor(rgb: 0xB9D078, alpha: 0.16)))
    case .feedbackWarning:
      return ColorSet(.auto(light: UIColor(rgb: 0xC58A28), dark: UIColor(rgb: 0xFACA7D)))
    case .feedbackWarningBg:
      return ColorSet(.auto(light: UIColor(rgb: 0xC58A28, alpha: 0.14), dark: UIColor(rgb: 0xFACA7D, alpha: 0.20)))
    case .feedbackError:
      return ColorSet(.auto(light: UIColor(rgb: 0xA03C2D), dark: UIColor(rgb: 0xDC8078)))
    case .feedbackErrorBg:
      return ColorSet(.auto(light: UIColor(rgb: 0xC84B38, alpha: 0.14), dark: UIColor(rgb: 0xDC8078, alpha: 0.20)))
    case .feedbackInfo:
      return ColorSet(.auto(light: UIColor(rgb: 0x94497D), dark: UIColor(rgb: 0xF9A5DB)))
    case .feedbackInfoBg:
      return ColorSet(.auto(light: UIColor(rgb: 0x94497D, alpha: 0.12), dark: UIColor(rgb: 0xF895D9, alpha: 0.20)))
    case .feedbackInformation:
      return ColorSet(.auto(light: UIColor(rgb: 0x2D6AB0), dark: UIColor(rgb: 0x8EB9E9)))
    case .feedbackInformationBg:
      return ColorSet(.auto(light: UIColor(rgb: 0x428BDB, alpha: 0.12), dark: UIColor(rgb: 0x68A2E2, alpha: 0.20)))

    // MARK: Form Controls

    case .formInputBg:
      return ColorSet(.auto(light: UIColor(rgb: 0x7C787C, alpha: 0.16), dark: UIColor(rgb: 0x7C797C, alpha: 0.32)))
    case .formInputText:
      return ColorSet(.auto(light: UIColor(rgb: 0x131213), dark: UIColor(rgb: 0xF7F4F7)))
    case .formInputBorderFocused:
      return ColorSet(.auto(light: UIColor(rgb: 0x61734B), dark: UIColor(rgb: 0x7F9762)))
    case .formInputBorderError:
      return ColorSet(.auto(light: UIColor(rgb: 0xC84B38), dark: UIColor(rgb: 0xE56757)))
    case .formPlaceholder:
      return ColorSet(.auto(light: UIColor(rgb: 0x131213, alpha: 0.6), dark: UIColor(rgb: 0xF6F3F6, alpha: 0.6)))
    case .formCursor:
      return ColorSet(.auto(light: UIColor(rgb: 0x61734B), dark: UIColor(rgb: 0x7F9762)))
    case .formSelectionBg:
      return ColorSet(.auto(light: UIColor(rgb: 0x61734B, alpha: 0.20), dark: UIColor(rgb: 0x7F9762, alpha: 0.25)))
    case .formToggleOff:
      return ColorSet(.auto(light: UIColor(rgb: 0x131213, alpha: 0.3), dark: UIColor(rgb: 0xF6F3F6, alpha: 0.3)))
    case .formToggleOn:
      return ColorSet(.auto(light: UIColor(rgb: 0x61734B), dark: UIColor(rgb: 0x7F9762)))
    case .formToggleThumb:
      return ColorSet(.static(UIColor(rgb: 0xFFFFFF)))
    case .formCheckboxOff:
      return ColorSet(.auto(light: UIColor(rgb: 0xD6D3D6), dark: UIColor(rgb: 0x2A292A)))
    case .formCheckboxOn:
      return ColorSet(.auto(light: UIColor(rgb: 0x61734B), dark: UIColor(rgb: 0x7F9762)))

    // MARK: Navigation

    case .navBarBg:
      return ColorSet(.auto(light: UIColor(rgb: 0xFFFFFF, alpha: 0.85), dark: UIColor(rgb: 0x131213, alpha: 0.85)))

    // MARK: Avatar

    case .avatar1:
      return ColorSet(.auto(light: UIColor(rgb: 0x66CDEA), dark: UIColor(rgb: 0x85D7EE)))
    case .avatar2:
      return ColorSet(.auto(light: UIColor(rgb: 0xF67AD0), dark: UIColor(rgb: 0xF88FD4)))
    case .avatar3:
      return ColorSet(.auto(light: UIColor(rgb: 0x20D3C1), dark: UIColor(rgb: 0x31DACC)))
    case .avatar4:
      return ColorSet(.auto(light: UIColor(rgb: 0x917FFA), dark: UIColor(rgb: 0xA799FB)))
    case .avatar5:
      return ColorSet(.auto(light: UIColor(rgb: 0xF6AC32), dark: UIColor(rgb: 0xFAB84B)))
    case .avatar6:
      return ColorSet(.auto(light: UIColor(rgb: 0xDDC02D), dark: UIColor(rgb: 0xF6D532)))
    case .avatar7:
      return ColorSet(.auto(light: UIColor(rgb: 0x428BDB), dark: UIColor(rgb: 0x68A2E2)))
    case .avatar8:
      return ColorSet(.auto(light: UIColor(rgb: 0x5DCAD2), dark: UIColor(rgb: 0x7DD5DB)))
    case .avatarText:
      return ColorSet(.static(UIColor(rgb: 0xFFFFFF)))
    case .avatarTextDark:
      return ColorSet(.static(UIColor(rgb: 0x131213)))

    // MARK: Progress & Rating

    case .progressTrack:
      return ColorSet(.auto(light: UIColor(rgb: 0x7C787C, alpha: 0.20), dark: UIColor(rgb: 0x7C797C, alpha: 0.36)))
    case .progressFill:
      return ColorSet(.auto(light: UIColor(rgb: 0x61734B), dark: UIColor(rgb: 0x7F9762)))
    case .progressSuccess:
      return ColorSet(.auto(light: UIColor(rgb: 0x61734B), dark: UIColor(rgb: 0x7F9762)))
    case .ratingFilled:
      return ColorSet(.auto(light: UIColor(rgb: 0xDDC02D), dark: UIColor(rgb: 0xF8DD5B)))
    case .ratingEmpty:
      return ColorSet(.auto(light: UIColor(rgb: 0x7C787C, alpha: 0.20), dark: UIColor(rgb: 0x7C797C, alpha: 0.36)))
    case .sliderThumb:
      return ColorSet(.static(UIColor(rgb: 0xFFFFFF)))
    case .sliderTrack:
      return ColorSet(.auto(light: UIColor(rgb: 0x7C787C, alpha: 0.20), dark: UIColor(rgb: 0x7C797C, alpha: 0.36)))
    case .sliderFill:
      return ColorSet(.auto(light: UIColor(rgb: 0x61734B), dark: UIColor(rgb: 0x7F9762)))

    // MARK: Presence

    case .presenceOnline:
      return ColorSet(.auto(light: UIColor(rgb: 0x7F9762), dark: UIColor(rgb: 0x9EB46D)))
    case .presenceAway:
      return ColorSet(.auto(light: UIColor(rgb: 0xDDC02D), dark: UIColor(rgb: 0xF8DD5B)))
    case .presenceBusy:
      return ColorSet(.auto(light: UIColor(rgb: 0xC84B38), dark: UIColor(rgb: 0xE56757)))
    case .presenceOffline:
      return ColorSet(.auto(light: UIColor(rgb: 0x7C787C), dark: UIColor(rgb: 0x5C595C)))

    // MARK: Badges

    case .badgeDefault:
      return ColorSet(.auto(light: UIColor(rgb: 0xC84B38), dark: UIColor(rgb: 0xE56757)))
    case .badgeText:
      return ColorSet(.static(UIColor(rgb: 0xFFFFFF)))

    // MARK: Tags

    case .tagDefault:
      return ColorSet(.auto(light: UIColor(rgb: 0x7C787C, alpha: 0.12), dark: UIColor(rgb: 0x7C797C, alpha: 0.24)))
    case .tagDefaultText:
      return ColorSet(.auto(light: UIColor(rgb: 0x131213), dark: UIColor(rgb: 0xF7F4F7)))

    // MARK: Chips

    case .chipDefault:
      return ColorSet(.auto(light: UIColor(rgb: 0x7C787C, alpha: 0.12), dark: UIColor(rgb: 0x7C797C, alpha: 0.24)))
    case .chipDefaultText:
      return ColorSet(.auto(light: UIColor(rgb: 0x131213), dark: UIColor(rgb: 0xF7F4F7)))
    case .chipSelected:
      return ColorSet(.auto(light: UIColor(rgb: 0x7F9762, alpha: 0.50), dark: UIColor(rgb: 0x61734B, alpha: 0.50)))
    case .chipSelectedText:
      return ColorSet(.auto(light: UIColor(rgb: 0x282E1E), dark: UIColor(rgb: 0xCEDFA0)))

    // MARK: Skeleton

    case .skeletonBase:
      return ColorSet(.auto(light: UIColor(rgb: 0xE9E7E9), dark: UIColor(rgb: 0x2A292A)))
    case .skeletonHighlight:
      return ColorSet(.auto(light: UIColor(rgb: 0xF7F4F7), dark: UIColor(rgb: 0x3D3C3D)))

    // MARK: Icon Tiles

    case .iconTileBackground:
      return ColorSet(.auto(light: UIColor(rgb: 0x61734B, alpha: 0.12), dark: UIColor(rgb: 0xB9D078, alpha: 0.16)))
    case .iconTileIcon:
      return ColorSet(.auto(light: UIColor(rgb: 0x3B452D), dark: UIColor(rgb: 0xCEDFA0)))

    // MARK: Charts: Diverging

    case .chartDivergingNegative:
      return ColorSet(.auto(light: UIColor(rgb: 0xE56757), dark: UIColor(rgb: 0xE56757)))
    case .chartDivergingNeutral:
      return ColorSet(.auto(light: UIColor(rgb: 0xD6D3D6), dark: UIColor(rgb: 0xD6D3D6)))
    case .chartDivergingPositive:
      return ColorSet(.auto(light: UIColor(rgb: 0x66CDEA), dark: UIColor(rgb: 0x85D7EE)))

    // MARK: Charts: Sequential

    case .chartSequential1:
      return ColorSet(.static(UIColor(rgb: 0xFBBEE5)))
    case .chartSequential2:
      return ColorSet(.static(UIColor(rgb: 0xF9A5DB)))
    case .chartSequential3:
      return ColorSet(.static(UIColor(rgb: 0xF88FD4)))
    case .chartSequential4:
      return ColorSet(.static(UIColor(rgb: 0xC562A6)))
    case .chartSequential5:
      return ColorSet(.static(UIColor(rgb: 0x94497D)))

    // MARK: Charts: Categorical

    case .chartCategorical1:
      return ColorSet(.auto(light: UIColor(rgb: 0x20D3C1), dark: UIColor(rgb: 0x31DACC)))
    case .chartCategorical2:
      return ColorSet(.static(UIColor(rgb: 0x7F9762)))
    case .chartCategorical3:
      return ColorSet(.auto(light: UIColor(rgb: 0xF67AD0), dark: UIColor(rgb: 0xF88FD4)))
    case .chartCategorical4:
      return ColorSet(.auto(light: UIColor(rgb: 0x66CDEA), dark: UIColor(rgb: 0x85D7EE)))
    case .chartCategorical5:
      return ColorSet(.auto(light: UIColor(rgb: 0xDDC02D), dark: UIColor(rgb: 0xF6D532)))
    case .chartCategorical6:
      return ColorSet(.auto(light: UIColor(rgb: 0x917FFA), dark: UIColor(rgb: 0xA799FB)))
    }
  }
}

extension UIColor {
  public convenience init(rgb: UInt32, alpha: CGFloat = 1) {
    let components = (
      r: CGFloat((rgb >> 16) & 0xff) / 255.0,
      g: CGFloat((rgb >> 08) & 0xff) / 255.0,
      b: CGFloat((rgb >> 00) & 0xff) / 255.0
    )
    self.init(red: components.r, green: components.g, blue: components.b, alpha: alpha)
  }

  public convenience init(rgba: UInt32) {
    let components = (
      r: CGFloat((rgba >> 24) & 0xff) / 255.0,
      g: CGFloat((rgba >> 16) & 0xff) / 255.0,
      b: CGFloat((rgba >> 08) & 0xff) / 255.0,
      a: CGFloat((rgba >> 00) & 0xff) / 255.0
    )
    self.init(red: components.r, green: components.g, blue: components.b, alpha: components.a)
  }
}

extension Color {
  public init(rgb: UInt32, alpha: CGFloat = 1) {
    let components = (
      r: CGFloat((rgb >> 16) & 0xff) / 255.0,
      g: CGFloat((rgb >> 08) & 0xff) / 255.0,
      b: CGFloat((rgb >> 00) & 0xff) / 255.0
    )
    self.init(red: components.r, green: components.g, blue: components.b, opacity: alpha)
  }

  public init(rgba: UInt32) {
    let components = (
      r: CGFloat((rgba >> 24) & 0xff) / 255.0,
      g: CGFloat((rgba >> 16) & 0xff) / 255.0,
      b: CGFloat((rgba >> 08) & 0xff) / 255.0,
      a: CGFloat((rgba >> 00) & 0xff) / 255.0
    )
    self.init(red: components.r, green: components.g, blue: components.b, opacity: components.a)
  }
}
