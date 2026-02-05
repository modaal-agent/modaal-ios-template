// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import SimpleTheming
import SwiftUI

// MARK: - SemanticColor

extension MainTheme {
  public typealias _GradientAsset = SemanticGradient

  public func gradientSet(for asset: _GradientAsset) -> GradientSet {
    switch asset {
    case .mainColorBg:
      return GradientSet(.static(Gradient(colors: [
        Color(uiColor: UIColor(rgb: 0xFFFAF0)),
        Color(uiColor: UIColor(rgb: 0xFFF4E1)),
      ])))
    }
  }
}
