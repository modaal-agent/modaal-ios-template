// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import UIKit
import SimpleTheming

extension Theme: Themeable {
  public static let mainTheme = Theme(key: "mainTheme")

  public func themed() -> Themed {
    switch self {
    case .mainTheme:
      return MainTheme()
    default:
      fatalError("You are accessing undefined theme.")
    }
  }
}
