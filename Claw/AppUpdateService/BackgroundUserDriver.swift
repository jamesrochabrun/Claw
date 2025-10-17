//
//  BackgroundUserDriver.swift
//  Claw
//
//  Sparkle user driver that works silently in the background
//

import Foundation
import Sparkle
import OSLog

private let updateLogger = Logger(subsystem: "com.claw.updates", category: "sparkle")

// MARK: - BackgroundUserDriver

/// A Sparkle user driver that is not shown to the user (works in the background)
@MainActor
final class BackgroundUserDriver: NSObject, SPUUserDriver, Sendable {

  init(
    onReceivedUpdateInfo: @escaping @MainActor @Sendable (AppUpdateInfo) -> Void = { _ in },
    onReadyToInstall: @escaping @MainActor @Sendable () -> Void = { })
  {
    self.onReceivedUpdateInfo = onReceivedUpdateInfo
    self.onReadyToInstall = onReadyToInstall
  }

  func show(_: SPUUpdatePermissionRequest) async -> SUUpdatePermissionResponse {
    updateLogger.info("Showing update permission request")
    // IMPORTANT: sendSystemProfile set to false for user privacy
    return SUUpdatePermissionResponse(
      automaticUpdateChecks: true,
      automaticUpdateDownloading: true,
      sendSystemProfile: false)
  }

  func showUpdateReleaseNotes(with _: SPUDownloadData) {
    updateLogger.info("Showing update release notes")
  }

  func showUpdateReleaseNotesFailedToDownloadWithError(_ error: any Error) {
    updateLogger.info("Failed to download release notes: \(error.localizedDescription)")
  }

  func showUpdateNotFoundWithError(_ error: any Error, acknowledgement _: @escaping () -> Void) {
    updateLogger.info("Update not found with error: \(error.localizedDescription)")
  }

  func showDownloadInitiated(cancellation _: @escaping () -> Void) {
    updateLogger.info("Download initiated")
  }

  func showDownloadDidReceiveExpectedContentLength(_ expectedContentLength: UInt64) {
    updateLogger.info("Download expected content length: \(expectedContentLength) bytes")
  }

  func showDownloadDidReceiveData(ofLength length: UInt64) {
    updateLogger.debug("Download received data: \(length) bytes")
  }

  func showDownloadDidStartExtractingUpdate() {
    updateLogger.info("Started extracting update")
  }

  func showExtractionReceivedProgress(_ progress: Double) {
    updateLogger.debug("Extraction progress: \(Int(progress * 100))%")
  }

  func showReadyToInstallAndRelaunch() async -> SPUUserUpdateChoice {
    updateLogger.info("Ready to install and relaunch - dismissing")
    onReadyToInstall()
    return SPUUserUpdateChoice.dismiss
  }

  func showInstallingUpdate(
    withApplicationTerminated applicationTerminated: Bool,
    retryTerminatingApplication _: @escaping () -> Void)
  {
    updateLogger.info("Installing update (app terminated: \(applicationTerminated))")
  }

  func showUpdateInstalledAndRelaunched(_ relaunched: Bool, acknowledgement _: @escaping () -> Void) {
    updateLogger.info("Update installed and relaunched: \(relaunched)")
  }

  func showUpdateInFocus() {
    updateLogger.info("Update in focus")
  }

  func showUserInitiatedUpdateCheck(cancellation _: @escaping () -> Void) {
    updateLogger.info("User initiated update check")
  }

  func showUpdateFound(
    with updateItem: SUAppcastItem,
    state _: SPUUserUpdateState,
    reply: @escaping (SPUUserUpdateChoice) -> Void)
  {
    updateLogger.log("Update found: \(updateItem.displayVersionString) (\(updateItem.versionString))")
    let appUpdateInfo = AppUpdateInfo(
      version: updateItem.versionString,
      fileURL: updateItem.fileURL,
      releaseNotesURL: updateItem.fullReleaseNotesURL)
    onReceivedUpdateInfo(appUpdateInfo)
    reply(.install)
  }

  func showDownloadedUpdate(_ updateItem: SUAppcastItem, acknowledgement: @escaping () -> Void) {
    updateLogger.info("Update downloaded: \(updateItem.displayVersionString)")
    acknowledgement()
  }

  func showInstallingUpdate(withApplicationTerminated terminated: Bool) {
    updateLogger.info("Installing update (app terminated: \(terminated))")
  }

  func showUpdateInstallationDidFinish() {
    updateLogger.info("Update installation finished")
  }

  func showUpdateInstallationDidCancel() {
    updateLogger.info("Update installation cancelled")
  }

  func dismissUpdateInstallation() {
    updateLogger.info("Dismissing update installation")
  }

  func showUpdaterError(_ error: Error, acknowledgement: @escaping () -> Void) {
    updateLogger.error("Updater error: \(error.localizedDescription)")
    acknowledgement()
  }

  func showUpdateNotFoundAcknowledgement(completion: @escaping () -> Void) {
    updateLogger.info("No update found - app is up to date")
    completion()
  }

  private let onReceivedUpdateInfo: @MainActor @Sendable (AppUpdateInfo) -> Void
  private let onReadyToInstall: @MainActor @Sendable () -> Void
}
