// (c) Copyright Modaal.dev 2026

import UIKit
import SimpleTheming
import SwiftUI

public enum SemanticColor: ColorAssetable {
  case accentPrimary
  case accentSecondary

  case backgroundPrimary
  case backgroundSecondary

  case textPrimary
  case textSecondary
}

public extension ThemeProviding {
  func semanticColor(_ semanticColor: SemanticColor, preferredAppearance: PreferredAppearance? = nil, on theme: Theme? = nil) -> UIColor {

    return self.color(for: semanticColor, preferredAppearance: preferredAppearance, on: theme)
  }

  func color(_ semanticColor: SemanticColor, preferredAppearance: PreferredAppearance? = nil, on theme: Theme? = nil) -> Color {

    return Color(self.color(for: semanticColor, preferredAppearance: preferredAppearance, on: theme))
  }
}
