//(c) Copyright Modaal.dev 2026

import UIKit
import SwiftUI
import SimpleTheming

// MARK: - SemanticFont

extension MainTheme {
  enum Typography {
    enum Family: String {
      case primary = "SF Pro Text"
      case display = "Outfit"
    }

    enum Weight: Int {
      case regular = 400
      case medium = 500
      case semibold = 600
      case bold = 700
    }

    enum Size: Int {
      case _50 = 11
      case _100 = 12
      case _200 = 13
      case _300 = 15
      case _400 = 16
      case _500 = 17
      case _600 = 20
      case _700 = 22
      case _800 = 28
      case _900 = 34
      case _950 = 40
    }

    enum LineHeight: Int {
      case _50 = 13
      case _100 = 16
      case _200 = 18
      case _300 = 20
      case _400 = 21
      case _500 = 22
      case _600 = 25
      case _700 = 28
      case _800 = 34
      case _900 = 41
      case _950 = 48
    }

    enum Tracking: Float {
      case `default` = 0
      case tight = -0.3
      case loose = 0.3
    }
  }

  public typealias _FontAsset = SemanticFont

  private static let fontsRegistered = {
    let fontURLs = Outfit_FileNames.allCases.compactMap {
      Bundle.module.url(forResource: $0.rawValue, withExtension: nil)
    }

    guard !fontURLs.isEmpty else {
      fatalError("Font files (\(Outfit_FileNames.allCases) not found in the bundle \(Bundle.module)")
    }

    CTFontManagerRegisterFontURLs(fontURLs as CFArray, CTFontManagerScope.process, true, nil)

    return true
  }()

  public func fontSet(for asset: _FontAsset) -> FontSet {
    let fontProperties = asset.fontProperties
    let font = UIFontMetrics(forTextStyle: asset.textStyle)
      .scaledFont(for: loadFont(name: fontProperties.name, size: fontProperties.size))
    return FontSet(.static(font), fontMetrics: FontMetrics(pointSize: fontProperties.size, lineHeight: fontProperties.lineHeight, letterSpacing: fontProperties.letterSpacing))
  }

  private func loadFont(name fontName: FontName, size: CGFloat) -> UIFont {
    guard MainTheme.fontsRegistered else { return UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 11)) }

    let font: UIFont
    switch fontName {
    case .name(let fontName):
      font = UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size)
    case .system(let font_):
      font = font_.withSize(size)
    }

    return font
  }
}

fileprivate extension SemanticFont {
  var textStyle: UIFont.TextStyle {
    switch self {
    case .largeTitle:
      return .largeTitle

    case .title1:
      return .title1
    case .title2:
      return .title2
    case .title3:
      return .title3

    case .headline:
      return .headline

    case .bodyRegular:
      return .body
    case .bodyMedium:
      return .body
    case .bodyEmphasized:
      return .body

    case .calloutRegular:
      return .callout
    case .calloutEmphasized:
      return .callout

    case .subheadRegular:
      return .subheadline
    case .subheadMedium:
      return .subheadline
    case .subheadEmphasized:
      return .subheadline

    case .footnoteRegular:
      return .footnote
    case .footnoteMedium:
      return .footnote
    case .footnoteEmphasized:
      return .footnote

    case .caption1Regular:
      return .caption1
    case .caption1Emphasized:
      return .caption1

    case .caption2Regular:
      return .caption2
    case .caption2Emphasized:
      return .caption2
    }
  }

  var fontProperties: (name: FontName, size: CGFloat, lineHeight: CGFloat, letterSpacing: LetterSpacing) {
    /// Synced with Figma: 31.05.2024
    switch self {
    case .largeTitle:
      return (name: .outfit_semibold, size: 34, lineHeight: 41, letterSpacing: 0.pct)

    case .title1:
      return (name: .outfit_semibold, size: 28, lineHeight: 34, letterSpacing: 0.pct)
    case .title2:
      return (name: .outfit_semibold, size: 22, lineHeight: 28, letterSpacing: 0.pct)
    case .title3:
      return (name: .outfit_semibold, size: 20, lineHeight: 25, letterSpacing: 0.pct)

    case .headline:
      return (name: .sfProText_semibold, size: 17, lineHeight: 22, letterSpacing: 0.pct)

    case .bodyRegular:
      return (name: .sfProText_regular, size: 17, lineHeight: 22, letterSpacing: 0.pct)
    case .bodyMedium:
      return (name: .sfProText_medium, size: 17, lineHeight: 22, letterSpacing: 0.pct)
    case .bodyEmphasized:
      return (name: .sfProText_semibold, size: 17, lineHeight: 22, letterSpacing: 0.pct)

    case .calloutRegular:
      return (name: .sfProText_regular, size: 16, lineHeight: 21, letterSpacing: 0.pct)
    case .calloutEmphasized:
      return (name: .sfProText_semibold, size: 16, lineHeight: 21, letterSpacing: 0.pct)

    case .subheadRegular:
      return (name: .sfProText_regular, size: 15, lineHeight: 20, letterSpacing: 0.pct)
    case .subheadMedium:
      return (name: .sfProText_medium, size: 15, lineHeight: 20, letterSpacing: 0.pct)
    case .subheadEmphasized:
      return (name: .sfProText_semibold, size: 15, lineHeight: 20, letterSpacing: 0.pct)

    case .footnoteRegular:
      return (name: .sfProText_regular, size: 13, lineHeight: 18, letterSpacing: 0.pct)
    case .footnoteMedium:
      return (name: .sfProText_medium, size: 13, lineHeight: 18, letterSpacing: 0.pct)
    case .footnoteEmphasized:
      return (name: .sfProText_semibold, size: 13, lineHeight: 18, letterSpacing: 0.pct)

    case .caption1Regular:
      return (name: .sfProText_regular, size: 12, lineHeight: 16, letterSpacing: 0.pct)
    case .caption1Emphasized:
      return (name: .sfProText_semibold, size: 12, lineHeight: 16, letterSpacing: 0.pct)

    case .caption2Regular:
      return (name: .sfProText_regular, size: 11, lineHeight: 13, letterSpacing: 0.pct)
    case .caption2Emphasized:
      return (name: .sfProText_semibold, size: 11, lineHeight: 13, letterSpacing: 0.pct)
    }
  }
}

fileprivate enum Outfit_FileNames: String, CaseIterable {
  case variable = "Outfit-VariableFont_wght.ttf"
  case semibold = "Outfit-SemiBold.ttf"
}

fileprivate enum FontName {
  case name(String)
  case system(UIFont)

  static var outfit_semibold: Self = .name("Outfit-SemiBold")

  static var sfProText_semibold: Self = .system(.systemFont(ofSize: 11, weight: .semibold))
  static var sfProText_medium: Self = .system(.systemFont(ofSize: 11, weight: .medium))
  static var sfProText_regular: Self = .system(.systemFont(ofSize: 11, weight: .regular))
}
