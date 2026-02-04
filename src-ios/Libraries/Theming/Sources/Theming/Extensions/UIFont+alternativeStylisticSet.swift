// (c) Copyright Modaal.dev 2026

import Foundation
import CoreText
import UIKit

/**!
 https://stackoverflow.com/questions/59464935/uifont-how-to-use-stylistic-alternate-character
 */

extension UIFont {

  /// Returns the font, applying an alternative stylistic style set.
  public func withAlternativeStylisticSet(withName name: String) -> UIFont? {
    guard let identifier = alternativeStylisticSetIdentifier(withName: name) else {
      return nil
    }

    let settings: [UIFontDescriptor.FeatureKey: Int] = [
      .featureIdentifier: kStylisticAlternativesType,
      .typeIdentifier: identifier
    ]

    let fontDescriptor = self.fontDescriptor.addingAttributes([.featureSettings: [settings]])
    return UIFont(descriptor: fontDescriptor, size: 0)
  }

  /// Returns the identifier for an alternative stylistic set
  private func alternativeStylisticSetIdentifier(withName selectorName: String) -> Int? {
    guard let ctFeatures = CTFontCopyFeatures(self) else {
      return nil
    }

    let features = ctFeatures as [AnyObject] as NSArray
    for feature in features {
      if let featureDict = feature as? [String: Any] {
        if let typeName = featureDict[kCTFontFeatureTypeNameKey as String] as? String {
          if typeName == "Alternative Stylistic Sets" {
            if let featureTypeSelectors = featureDict[kCTFontFeatureTypeSelectorsKey as String] as? NSArray {
              for featureTypeSelector in featureTypeSelectors {
                if let featureTypeSelectorDict = featureTypeSelector as? [String: Any] {
                  if let name = featureTypeSelectorDict[kCTFontFeatureSelectorNameKey as String] as? String, let identifier = featureTypeSelectorDict[kCTFontFeatureSelectorIdentifierKey as String] as? Int {
                    if name == selectorName {
                      return identifier
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    return nil
  }
}
