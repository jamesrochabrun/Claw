//
//  UpdateChecker.swift
//  Claw
//
//  Helper that checks for updates once using Sparkle
//

import Foundation
import Sparkle
import OSLog

private let updateLogger = Logger(subsystem: "com.claw.updates", category: "checker")

// MARK: - UpdateChecker

/// A helper that checks for updates once
@MainActor
final class UpdateChecker: NSObject {

  override init() {
    super.init()
    setupUpdater()
  }

  func checkForUpdates() async throws -> AppUpdateResult {
    if updater?.sessionInProgress == true {
      throw NSError(domain: "ClawUpdateError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Update already in progress"])
    }

    return try await withCheckedThrowingContinuation { continuation in
      guard self.continuation == nil else {
        continuation.resume(throwing: NSError(domain: "ClawUpdateError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Update already in progress"]))
        return
      }

      self.continuation = continuation

      // Remove the key used by Sparkle to avoid the update being delayed / cached
      UserDefaults.standard.removeObject(forKey: "SULastCheckTime")

      try? updater?.start()
      updater?.resetUpdateCycle()
      updater?.checkForUpdates()
    }
  }

  private var updateInfo: AppUpdateInfo?
  private var updater: SPUUpdater?
  private var continuation: CheckedContinuation<AppUpdateResult, Error>?

  /// Ideally this would be part of the initializer, but Swift has issues with type checking some initializers
  private func setupUpdater() {
    let hostBundle = Bundle.main
    let applicationBundle = Bundle.main
    let userDriver = BackgroundUserDriver(
      onReceivedUpdateInfo: { @MainActor [weak self] updateInfo in
        self?.updateInfo = updateInfo
      },
      onReadyToInstall: { @MainActor [weak self] in
        self?.complete(with: .success(.updateAvailable(info: self?.updateInfo)))
      })

    updater = SPUUpdater(
      hostBundle: hostBundle,
      applicationBundle: applicationBundle,
      userDriver: userDriver,
      delegate: self)
  }

  private func complete(with result: Result<AppUpdateResult, Error>) {
    continuation?.resume(with: result)
    continuation = nil
  }
}

// MARK: - SPUUpdaterDelegate

extension UpdateChecker: SPUUpdaterDelegate {

  func allowedChannels(for _: SPUUpdater) -> Set<String> {
    // For now, use "stable" channel. Could be made configurable later
    let channel = "stable"
    updateLogger.info("allowedChannels(for:) - using channel: \(channel)")
    return [channel]
  }

  func updaterShouldPromptForPermissionToCheck(forUpdates _: SPUUpdater) -> Bool {
    updateLogger.info("updaterShouldPromptForPermissionToCheck(forUpdates:)")
    return false
  }

  func updater(_: SPUUpdater, didDownloadUpdate _: SUAppcastItem) {
    updateLogger.info("updater(_:didDownloadUpdate:)")
  }

  func updater(_: SPUUpdater, didExtractUpdate _: SUAppcastItem) {
    updateLogger.info("updater(_:didExtractUpdate:)")
  }

  func updater(_: SPUUpdater, shouldProceedWithUpdate _: SUAppcastItem, updateCheck _: SPUUpdateCheck) throws {
    updateLogger.info("updater(_:shouldProceedWithUpdate:updateCheck:)")
  }

  func updater(
    _: SPUUpdater,
    willInstallUpdateOnQuit _: SUAppcastItem,
    immediateInstallationBlock _: @escaping () -> Void)
    -> Bool
  {
    updateLogger.info("updater(willInstallUpdateOnQuit:)")
    return true
  }

  func updater(_: SPUUpdater, mayPerform _: SPUUpdateCheck) throws {
    updateLogger.info("updater(_:mayPerform:)")
  }

  func updaterDidNotFindUpdate(_: SPUUpdater, error: any Error) {
    let nsError = error as NSError
    if nsError.domain == SUSparkleErrorDomain, nsError.code == SUError.noUpdateError.rawValue {
      updateLogger.info("No update available")
    } else {
      updateLogger.error("updaterDidNotFindUpdate(_:error:) - \(error.localizedDescription)")
    }
    complete(with: .success(.noUpdateAvailable))
  }

  func updaterWillRelaunchApplication(_: SPUUpdater) {
    updateLogger.info("updaterWillRelaunchApplication(_:)")
  }

  func bestValidUpdate(in appCast: SUAppcast, for _: SPUUpdater) -> SUAppcastItem? {
    updateLogger.info("bestValidUpdate(in:for:)")
    return appCast.items.first
  }

  func updaterMayCheck(forUpdates _: SPUUpdater) -> Bool {
    updateLogger.info("updaterMayCheck(forUpdates:)")
    return true
  }
}
