// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import UIKit
import SimpleTheming
import SwiftUI

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

public struct FontAndMetrics {
  public let font: Font
  public let measuredLineHeight: CGFloat
  public let metrics: FontMetrics

  public init(font: Font, measuredLineHeight: CGFloat, metrics: FontMetrics) {
    self.font = font
    self.measuredLineHeight = measuredLineHeight
    self.metrics = metrics
  }

  public func ignoringLineHeight() -> FontAndMetrics {
    return FontAndMetrics(
      font: font,
      measuredLineHeight: measuredLineHeight,
      metrics: FontMetrics(
        pointSize: metrics.pointSize,
        lineHeight: nil,
        letterSpacing: metrics.letterSpacing
      ))
  }
}

public extension ThemeProviding {
  func semanticFont(_ semanticFont: SemanticFont, preferredAppearance: PreferredAppearance? = nil, on theme: Theme? = nil) -> UIFont {

    return self.font(for: semanticFont, preferredAppearance: preferredAppearance, on: theme).0
  }

  func font(_ semanticFont: SemanticFont, preferredAppearance: PreferredAppearance? = nil, on theme: Theme? = nil) -> FontAndMetrics {

    let (font, metrics) = self.font(for: semanticFont, preferredAppearance: preferredAppearance, on: theme)
    return FontAndMetrics(
      font: Font(font),
      measuredLineHeight: font.lineHeight,
      metrics: metrics)
  }
}
