// (c) Copyright Modaal.dev 2026
//
// Based on https://github.com/dscyrescotti/SwiftTheming

import UIKit
import SwiftUI

public protocol ThemeProviderPersisting {
  func get<T: Codable>(_ type: T.Type, key: String) -> T?
  func set<T: Codable>(_ value: T, key: String)
}

public protocol ThemeProviding {
  func color(for asset: ColorAssetable, preferredAppearance: PreferredAppearance?, on theme: Theme?) -> UIColor
  func image(for asset: ImageAssetable, preferredAppearance: PreferredAppearance?, on theme: Theme?) -> UIImage
  func font(for asset: FontAssetable, preferredAppearance: PreferredAppearance?, on theme: Theme?) -> (font: UIFont, metrics: FontMetrics)
  func gradient(for asset: GradientAssetable, preferredAppearance: PreferredAppearance?, on theme: Theme?) -> Gradient
}

public extension ThemeProviding {
  func color(for asset: ColorAssetable, preferredAppearance: PreferredAppearance?) -> UIColor {
    color(for: asset, preferredAppearance: preferredAppearance, on: nil)
  }
  func color(for asset: ColorAssetable, on theme: Theme?) -> UIColor {
    color(for: asset, preferredAppearance: nil, on: theme)
  }
  func color(for asset: ColorAssetable) -> UIColor {
    color(for: asset, preferredAppearance: nil, on: nil)
  }

  func image(for asset: ImageAssetable, preferredAppearance: PreferredAppearance?) -> UIImage {
    image(for: asset, preferredAppearance: preferredAppearance, on: nil)
  }
  func image(for asset: ImageAssetable, on theme: Theme?) -> UIImage {
    image(for: asset, preferredAppearance: nil, on: theme)
  }
  func image(for asset: ImageAssetable) -> UIImage {
    image(for: asset, preferredAppearance: nil, on: nil)
  }

  func font(for asset: FontAssetable, preferredAppearance: PreferredAppearance?) -> (font: UIFont, metrics: FontMetrics) {
    font(for: asset, preferredAppearance: preferredAppearance, on: nil)
  }
  func font(for asset: FontAssetable, on theme: Theme?) -> (font: UIFont, metrics: FontMetrics) {
    font(for: asset, preferredAppearance: nil, on: theme)
  }
  func font(for asset: FontAssetable) -> (font: UIFont, metrics: FontMetrics) {
    font(for: asset, preferredAppearance: nil, on: nil)
  }

  func gradient(for asset: GradientAssetable, preferredAppearance: PreferredAppearance?) -> Gradient {
    gradient(for: asset, preferredAppearance: preferredAppearance, on: nil)
  }
  func gradient(for asset: GradientAssetable, on theme: Theme?) -> Gradient {
    gradient(for: asset, preferredAppearance: nil, on: theme)
  }
  func gradient(for asset: GradientAssetable) -> Gradient {
    gradient(for: asset, preferredAppearance: nil, on: nil)
  }
}

public protocol ThemeProvidingUpdating: ThemeProviding {
  func setTheme(with theme: Theme)
  func setPreferredAppearance(with appearance: PreferredAppearance)
}

/// An observable object that manages predefined themes and appearances of an app.
public class ThemeProvider: ThemeProvidingUpdating {

  private let persistentStorage: ThemeProviderPersisting

  /// A current theme of an app. Loaded from the persistent storage, or default
  public private(set) var theme: Theme
  /// A current preferred appearance of an app. Loaded from the persistent storage, or default
  public private(set) var preferredAppearance: PreferredAppearance

  /// A list of keys to be used to store and fetch theme and appearance.
  enum Key: String {
    /// A key for theme to store and fetch in user defaults.
    case theme = "theming.theme.key"
    /// A key for preferred appearance to store and fetch in user defaults.
    case preferredAppearance = "theming.preferredAppearance.key"
  }

  public init(
    persistentStorage: ThemeProviderPersisting,
    defaultTheme: Theme,
    defaultPreferredAppearance: PreferredAppearance
  ) {
    self.persistentStorage = persistentStorage
    self.theme = persistentStorage.get(Theme.self, key: Key.theme.rawValue) ?? defaultTheme
    self.preferredAppearance = persistentStorage.get(PreferredAppearance.self, key: Key.preferredAppearance.rawValue) ?? defaultPreferredAppearance
  }

  // MARK: - color
  /// A method that returns color of a given asset and allows to override the preferred appearance and the current theme optionally.
  /// - Parameters:
  ///   - asset: asset for color
  ///   - preferredAppearance: preferred appearance to override
  ///   - theme: theme to override
  /// - Returns: color
  public func color(for asset: ColorAssetable, preferredAppearance: PreferredAppearance?, on theme: Theme?) -> UIColor
  {
    return (theme ?? self.theme)
      .colorSet(for: asset)
      .appearance
      .resolve(preferredAppearance: preferredAppearance ?? self.preferredAppearance)
  }

  // MARK: - image
  /// A method that returns image of a given asset and allows to override the preferred appearance and the current theme optionally.
  /// - Parameters:
  ///   - asset: asset for image
  ///   - preferredAppearance: preferred appearance to override
  ///   - theme: theme to override
  /// - Returns: image
  public func image(for asset: ImageAssetable, preferredAppearance: PreferredAppearance?, on theme: Theme?) -> UIImage
  {
    return (theme ?? self.theme)
      .imageSet(for: asset)
      .appearance
      .resolve(preferredAppearance: preferredAppearance ?? self.preferredAppearance)
  }

  // MARK: - font
  /// A method that returns font of a given asset and allows to override the preferred appearance and the current theme optionally.
  /// - Parameters:
  ///   - asset: asset for font
  ///   - preferredAppearance: preferred appearance to override
  ///   - theme: theme to override
  /// - Returns: font
  public func font(for asset: FontAssetable, preferredAppearance: PreferredAppearance?, on theme: Theme?) -> (font: UIFont, metrics: FontMetrics) {
    let fontSet = (theme ?? self.theme).fontSet(for: asset)
    let (appearance, metrics) = (fontSet.appearance, fontSet.fontMetrics)

    let font = appearance.resolve(preferredAppearance: preferredAppearance ?? self.preferredAppearance)
    return (font, metrics)
  }

  public func gradient(for asset: GradientAssetable, preferredAppearance: PreferredAppearance?, on theme: Theme?) -> Gradient
  {
    return (theme ?? self.theme)
      .gradientSet(for: asset)
      .appearance
      .resolve(preferredAppearance: preferredAppearance ?? self.preferredAppearance)
  }

  /// A method to change the current theme of an app.
  /// - Parameter theme: theme to which the current theme of an app is changed
  public func setTheme(with theme: Theme) {
    guard self.theme != theme else { return }
    self.theme = theme
    persistentStorage.set(theme, key: Key.theme.rawValue)
  }

  /// A method to change the preferred appearance of an app
  /// - Parameter appearance: appearance to which the preferred appearance of an app is changed
  public func setPreferredAppearance(with appearance: PreferredAppearance) {
    guard self.preferredAppearance != appearance else { return }
    self.preferredAppearance = appearance
    persistentStorage.set(appearance, key: Key.preferredAppearance.rawValue)
  }
}

private extension Appearance {
  func resolve(preferredAppearance: PreferredAppearance) -> T {
    switch self {
    case .static(let t):
      return t
    case .dynamic(let provider):
      switch preferredAppearance {
      case .system:
        return provider(UITraitCollection.current)
      case .light:
        return provider(UITraitCollection(userInterfaceStyle: .light))
      case .dark:
        return provider(UITraitCollection(userInterfaceStyle: .dark))
      }
    case .auto(let light, let dark):
      switch preferredAppearance {
      case .system:
        switch UITraitCollection.current.userInterfaceStyle {
        case .light: return light
        case .dark: return dark
        case .unspecified: return light
        @unknown default: return light
        }
      case .light:
        return light
      case .dark:
        return dark
      }
    }
  }
}
