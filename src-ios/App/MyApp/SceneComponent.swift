//
//  SceneComponent.swift
//  MyApp
//
//  Created by AI Assistant on 2025.
//

import RIBs
import MyAppMain

final class SceneComponent: Component<EmptyDependency>, RootDependency {
  init() {
    super.init(dependency: EmptyComponent())
  }
}
