//
//  AppUpdateService.swift
//  Claw
//
//  Protocol for app update functionality
//

import Combine
import Foundation

// MARK: - AppUpdateService

/// Service for checking and managing app updates
@MainActor
protocol AppUpdateService: Sendable {
  /// Current update availability status
  var hasUpdateAvailable: AsyncStream<AppUpdateResult> { get }

  /// Stop checking for updates
  func stopCheckingForUpdates()

  /// Start checking for updates continuously
  func checkForUpdatesContinuously()

  /// Relaunch the app to install an available update
  func relaunch()

  /// Check if a specific update is ignored
  func isUpdateIgnored(_ update: AppUpdateInfo?) -> Bool

  /// Ignore a specific update version
  func ignore(update: AppUpdateInfo?)
}
