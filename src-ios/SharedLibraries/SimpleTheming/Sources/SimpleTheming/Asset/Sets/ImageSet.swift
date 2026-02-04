// (c) Copyright Modaal.dev 2026
//
// Based on https://github.com/dscyrescotti/SwiftTheming

import UIKit

/// A image set to define images based on light and dark appearances.
public struct ImageSet {
  let appearance: Appearance<UIImage>

  public init(_ appearance: Appearance<UIImage>) {
    self.appearance = appearance
  }
}
