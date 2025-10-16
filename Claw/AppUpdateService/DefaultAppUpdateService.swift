//
//  DefaultAppUpdateService.swift
//  Claw
//
//  Default implementation of AppUpdateService
//

import Foundation
import OSLog

private let updateLogger = Logger(subsystem: "com.claw.updates", category: "service")

// MARK: - DefaultAppUpdateService

@MainActor
final class DefaultAppUpdateService: AppUpdateService {

  init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults
    monitorSettingChanges()
  }

  var hasUpdateAvailable: AsyncStream<AppUpdateResult> {
    AsyncStream { continuation in
      self.continuations.append(continuation)
      // Send current value immediately
      continuation.yield(_currentUpdateResult)

      continuation.onTermination = { [weak self] _ in
        guard let self = self else { return }
        self.continuations.removeAll { $0 === continuation }
      }
    }
  }

  func stopCheckingForUpdates() {
    canCheckForUpdates = false
    updateTask?.cancel()
    updateTask = nil
  }

  func checkForUpdatesContinuously() {
    #if DEBUG
    // Only check for updates in release builds
    updateLogger.info("Skipping update checks in DEBUG build")
    return
    #else
    canCheckForUpdates = true
    startCheckingForUpdates()
    #endif
  }

  func relaunch() {
    Task { @MainActor in
      // When an update is available, checking again for an update will make Sparkle quit and relaunch
      let updater = UpdateChecker()
      _ = try? await updater.checkForUpdates()
    }
  }

  func isUpdateIgnored(_ update: AppUpdateInfo?) -> Bool {
    guard let update else { return false }
    return ignoredUpdateVersions.contains(update.version)
  }

  func ignore(update: AppUpdateInfo?) {
    guard let update else {
      updateLogger.error("No version provided to ignore update")
      return
    }

    let ignoredVersions = ignoredUpdateVersions + [update.version]
    if let data = try? JSONEncoder().encode(ignoredVersions),
       let jsonString = String(data: data, encoding: .utf8) {
      userDefaults.set(jsonString, forKey: Self.ignoredVersionKey)
      updateLogger.info("Ignored update version: \(update.version)")
    }
  }

  // MARK: - Private

  private static let ignoredVersionKey = "AppUpdateService.ignoredVersion"
  private static let autoCheckSettingKey = "AppUpdateService.automaticallyCheckForUpdates"

  private let userDefaults: UserDefaults
  private let delayBetweenChecks: Duration = .seconds(60 * 60) // Check every hour

  private var _currentUpdateResult: AppUpdateResult = .noUpdateAvailable {
    didSet {
      // Notify all continuations
      for continuation in continuations {
        continuation.yield(_currentUpdateResult)
      }
    }
  }

  private var continuations: [AsyncStream<AppUpdateResult>.Continuation] = []
  private var canCheckForUpdates = false
  private var updateTask: Task<Void, Never>?

  private var ignoredUpdateVersions: [String] {
    guard let jsonString = userDefaults.string(forKey: Self.ignoredVersionKey),
          let data = jsonString.data(using: .utf8),
          let versions = try? JSONDecoder().decode([String].self, from: data) else {
      return []
    }
    return versions
  }

  private var automaticallyCheckForUpdates: Bool {
    get {
      // Default to true if not set
      if userDefaults.object(forKey: Self.autoCheckSettingKey) == nil {
        return true
      }
      return userDefaults.bool(forKey: Self.autoCheckSettingKey)
    }
    set {
      userDefaults.set(newValue, forKey: Self.autoCheckSettingKey)
    }
  }

  private func monitorSettingChanges() {
    // Start checking if enabled by default
    if automaticallyCheckForUpdates {
      checkForUpdatesContinuously()
    }

    // Monitor changes to the setting
    NotificationCenter.default.addObserver(
      forName: UserDefaults.didChangeNotification,
      object: nil,
      queue: .main) { [weak self] _ in
        guard let self = self else { return }
        if self.automaticallyCheckForUpdates {
          self.checkForUpdatesContinuously()
        } else {
          self.stopCheckingForUpdates()
        }
      }
  }

  private func startCheckingForUpdates() {
    updateTask?.cancel()
    updateTask = Task { @MainActor [weak self] in
      guard let self = self else { return }

      while canCheckForUpdates && !Task.isCancelled {
        guard _currentUpdateResult == .noUpdateAvailable else {
          // Stop checking if an update is already available
          updateLogger.info("Update already available, stopping periodic checks")
          break
        }

        do {
          let updater = UpdateChecker()
          let result = try await updater.checkForUpdates()
          _currentUpdateResult = result
          updateLogger.info("Update check completed: \(result == .noUpdateAvailable ? "no update" : "update available")")
        } catch {
          updateLogger.error("Update check failed: \(error.localizedDescription)")
        }

        // Wait before next check
        try? await Task.sleep(for: delayBetweenChecks)
      }
    }
  }
}
