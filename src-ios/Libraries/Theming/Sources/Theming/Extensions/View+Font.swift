// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import SwiftUI
import SimpleTheming

public extension View {
  func font(_ fontAndMetrics: FontAndMetrics) -> some View {
    font(fontAndMetrics.font)
      .lineSpacing(fontAndMetrics.metrics.lineHeight.map { $0 - fontAndMetrics.measuredLineHeight } ?? 0)
      .kerning(fontAndMetrics.metrics.letterSpacing.toPoints(fontAndMetrics.metrics.pointSize))
  }
}
