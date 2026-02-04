// (c) Copyright Modaal.dev 2026
//
// Based on https://github.com/dscyrescotti/SwiftTheming

import UIKit

/// A color set to define colors based on light and dark appearances.
public struct ColorSet {
  let appearance: Appearance<UIColor>

  public init(_ appearance: Appearance<UIColor>) {
    self.appearance = appearance
  }
}
