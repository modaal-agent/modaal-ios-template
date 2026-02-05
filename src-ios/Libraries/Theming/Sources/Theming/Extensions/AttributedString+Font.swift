// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation
import SimpleTheming
import SwiftUI

public extension AttributedString {
  mutating func setFont(_ fontAndMetrics: FontAndMetrics) {
    self.font = fontAndMetrics.font
    self.kern = fontAndMetrics.metrics.letterSpacing.toPoints(fontAndMetrics.metrics.pointSize)
    var paragraphStyle = NSMutableParagraphStyle()
    if let lineHeight = fontAndMetrics.metrics.lineHeight {
      paragraphStyle.minimumLineHeight = lineHeight
      paragraphStyle.maximumLineHeight = lineHeight
    }
    self.paragraphStyle = paragraphStyle
  }
}
