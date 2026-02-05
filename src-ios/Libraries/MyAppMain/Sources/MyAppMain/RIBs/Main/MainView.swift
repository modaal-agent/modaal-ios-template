// (c) Copyright Modaal.dev 2026

import CombineRIBs
import SimpleTheming
import SwiftUI
import Theming
import UIKit

final class MainViewController: UIHostingController<MainView>, MainPresentable, MainViewControllable {

  private let themeProvider: ThemeProviding
  private let viewState: MainViewState

  init(themeProvider: ThemeProviding) {
    self.themeProvider = themeProvider
    self.viewState = MainViewState()

    let view = MainView(
      themeProvider: themeProvider,
      viewState: viewState)

    super.init(rootView: view)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - MainPresentable

}

final class MainViewState: ObservableObject {
}

struct MainView: View {
  @Environment(\.colorScheme) var colorScheme
  private let themeProvider: ThemeProviding
  @ObservedObject private var viewState: MainViewState

  init(themeProvider: ThemeProviding, viewState: MainViewState) {
    self.themeProvider = themeProvider
    self._viewState = ObservedObject(wrappedValue: viewState)
  }

  var body: some View {
    ZStack {
      themeProvider.color(.backgroundPrimary)
        .ignoresSafeArea()

      NavigationView {
        ScrollView {
        }
        .background(themeProvider.color(.backgroundPrimary))
        .navigationTitle(LocalizedStringKey(localizable: .splashLogoSubtitle))
        .navigationBarTitleDisplayMode(.large)
      }
    }
  }
}
