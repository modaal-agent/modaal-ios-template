// (c) Copyright Modaal.dev 2026
//
// Based on https://github.com/dscyrescotti/SwiftTheming

import UIKit

public enum Appearance<T> {
  case `static`(T)
  case dynamic((UITraitCollection) -> T)
  case auto(light: T, dark: T)
}
