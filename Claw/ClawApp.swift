//
//  ClawApp.swift
//  Claw
//
//  Created by James Rochabrun on 9/20/25.
//

import SwiftUI

@main
struct ClawApp: App {

  private let updateService: AppUpdateService = DefaultAppUpdateService()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .onAppear {
          // Start checking for updates when app launches
          updateService.checkForUpdatesContinuously()
        }
    }
  }
}
