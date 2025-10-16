//
//  ClawApp.swift
//  Claw
//
//  Created by James Rochabrun on 9/20/25.
//

import SwiftUI

@main
struct ClawApp: App {

  @State private var updateService: AppUpdateService = DefaultAppUpdateService()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .onAppear {
          // Start checking for updates when app launches
          updateService.checkForUpdatesContinuously()
        }
        .environment(\.updateService, updateService)
    }
  }
}

// MARK: - Environment Key for AppUpdateService

private struct AppUpdateServiceKey: EnvironmentKey {
  static let defaultValue: AppUpdateService? = nil
}

extension EnvironmentValues {
  var updateService: AppUpdateService? {
    get { self[AppUpdateServiceKey.self] }
    set { self[AppUpdateServiceKey.self] = newValue }
  }
}
