// (c) Copyright Modaal.dev 2026
//
// Based on https://github.com/dscyrescotti/SwiftTheming

import UIKit
import SwiftUI

/// A color set to define colors based on light and dark appearances.
public struct GradientSet {
  let appearance: Appearance<Gradient>

  public init(_ appearance: Appearance<Gradient>) {
    self.appearance = appearance
  }
}
