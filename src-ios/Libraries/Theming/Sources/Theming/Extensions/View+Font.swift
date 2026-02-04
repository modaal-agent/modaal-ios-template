//(c) Copyright Modaal.dev 2026

import SwiftUI
import SimpleTheming

public extension View {
  func font(_ fontAndMetrics: FontAndMetrics) -> some View {
    font(fontAndMetrics.font)
      .lineSpacing(fontAndMetrics.metrics.lineHeight.map { $0 - fontAndMetrics.measuredLineHeight } ?? 0)
      .kerning(fontAndMetrics.metrics.letterSpacing.toPoints(fontAndMetrics.metrics.pointSize))
  }
}
