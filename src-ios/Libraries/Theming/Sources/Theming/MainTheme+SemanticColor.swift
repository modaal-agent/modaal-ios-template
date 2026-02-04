// (c) Copyright Modaal.dev 2026

import UIKit
import SimpleTheming
import SwiftUI

// MARK: - SemanticColor

extension MainTheme {
  public typealias _ColorAsset = SemanticColor

  public func colorSet(for asset: _ColorAsset) -> ColorSet {
    // Synced with Figma on 31.05.2024
    switch asset {

    case .accentPrimary:
      return ColorSet(.static(.init(rgb: 0xFCEECA)))
    case .accentSecondary:
      return ColorSet(.static(.init(rgb: 0x654E13)))

    case .backgroundPrimary:
      return ColorSet(.static(UIColor(rgb: 0xFFFAF0)))
    case .backgroundSecondary:
      return ColorSet(.static(UIColor(rgb: 0xF4F6F7)))

    case .textPrimary:
      return ColorSet(.static(UIColor(rgb: 0x383842)))
    case .textSecondary:
      return ColorSet(.static(UIColor(rgb: 0x47475B, alpha: 0.65)))
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
