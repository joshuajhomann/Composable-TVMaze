//
//  SceneDelegate.swift
//  Composable-TVMaze
//
//  Created by Joshua Homann on 5/31/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

    let rootView = TababarView(store:
      .init(
        initialState: AppState(),
        reducer: appReducer,
        environment: AppEnvironment()
      )
    )
    if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = UIHostingController(rootView: rootView)
      self.window = window
      window.makeKeyAndVisible()
    }
  }

}

