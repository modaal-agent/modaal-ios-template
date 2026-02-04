// (c) Copyright Modaal.dev 2026

import CombineRIBs
import SharedUtility
import SimpleTheming
import SwiftUI
import Theming
import UIKit

final class SplashViewController: UIHostingController<SplashView>, SplashPresentable, ViewControllable {

  var splashDidFinish: AnyActionHandler<Void>?

  private let themeProvider: ThemeProviding
  private let viewState: SplashViewState

  // Computed property creates AnyActionHandler that weakly captures self
  private var splashDidFinishHandler: AnyActionHandler<Void> {
    AnyActionHandler(self) { controller in
      controller.splashDidFinish?.invoke()
    }
  }

  init(themeProvider: ThemeProviding) {
    self.themeProvider = themeProvider
    self.viewState = SplashViewState()
    super.init(rootView: SplashView(themeProvider: themeProvider, viewState: viewState))
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.rootView = SplashView(
      themeProvider: themeProvider,
      viewState: viewState)
    .onFinish(splashDidFinishHandler)
  }
}

class SplashViewState: ObservableObject {
  @Published var localizedLogoSubtitle: LocalizedStringResource?
}

struct SplashView: View {
  private let themeProvider: ThemeProviding
  @ObservedObject private var viewState: SplashViewState
  private var onFinishHandler: AnyActionHandler<Void>?

  init(themeProvider: ThemeProviding, viewState: SplashViewState) {
    self.themeProvider = themeProvider
    self._viewState = ObservedObject(wrappedValue: viewState)
  }

  var body: some View {
    ZStack {
      themeProvider.color(.backgroundPrimary)
        .ignoresSafeArea()

      VStack(spacing: 20) {
        Text(localizable: .splashLogoSubtitle)
          .font(themeProvider.font(.largeTitle))
          .foregroundColor(themeProvider.color(.labelSecondary))
          .multilineTextAlignment(.center)

        if let localizedLogoSubtitle = viewState.localizedLogoSubtitle {
          Text(localizedLogoSubtitle)
            .font(themeProvider.font(.subheadMedium))
            .foregroundColor(themeProvider.color(.labelPrimary))
        }
      }
    }
    .onAppear {
      // Trigger finish after a delay
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        onFinishHandler?.invoke()
      }
    }
  }

  func onFinish(_ handler: AnyActionHandler<Void>?) -> Self {
    var copy = self
    copy.onFinishHandler = handler
    return copy
  }
}
