//
//  Models.swift
//  Claw
//
//  App update service models
//

import Foundation

// MARK: - AppUpdateInfo

/// Information about an available update
struct AppUpdateInfo: Sendable {
  let version: String
  let fileURL: URL?
  let releaseNotesURL: URL?
}

// MARK: - AppUpdateResult

/// Result of checking for updates
enum AppUpdateResult: Sendable, Equatable {
  case noUpdateAvailable
  case updateAvailable(info: AppUpdateInfo?)

  static func == (lhs: AppUpdateResult, rhs: AppUpdateResult) -> Bool {
    switch (lhs, rhs) {
    case (.noUpdateAvailable, .noUpdateAvailable):
      return true
    case (.updateAvailable(let lhsInfo), .updateAvailable(let rhsInfo)):
      return lhsInfo?.version == rhsInfo?.version
    default:
      return false
    }
  }
}
