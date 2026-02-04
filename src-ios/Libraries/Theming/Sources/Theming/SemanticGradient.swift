// (c) Copyright Modaal.dev 2026

import UIKit
import SimpleTheming
import SwiftUI

public enum SemanticGradient: GradientAssetable {
  case mainColorBg
}

public extension ThemeProviding {
  func gradient(_ semanticGradient: SemanticGradient, preferredAppearance: PreferredAppearance? = nil, on theme: Theme? = nil) -> Gradient {

    return self.gradient(for: semanticGradient, preferredAppearance: preferredAppearance, on: theme)
  }
}
