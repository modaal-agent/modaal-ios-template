// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import UIKit
import MyAppMain

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  var rootRouter: RootRouting?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let scene = (scene as? UIWindowScene) else {
      return
    }

    let window = UIWindow(windowScene: scene)

    let component = SceneComponent()
    let builder = RootBuilder(dependency: component)
    let router = builder.build()

    router.launch(from: window)

    self.window = window
    self.rootRouter = router
  }

  func sceneDidDisconnect(_ scene: UIScene) {
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
  }

  func sceneWillResignActive(_ scene: UIScene) {
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
  }
}
