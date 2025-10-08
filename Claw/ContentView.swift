//
//  ContentView.swift
//  Olive
//
//  Created by James Rochabrun on 9/20/25.
//

import SwiftUI
import ClaudeCodeCore
import ClaudeCodeSDK

struct ContentView: View {
  
  var config: ClaudeCodeConfiguration {
    // Start with the SDK's NVM-aware configuration
    var config = ClaudeCodeConfiguration.withNvmSupport()
    config.enableDebugLogging = true
    config.disallowedTools = ["MultiEdit"] // TODO: fix MultiEdit Tool.
    let homeDir = NSHomeDirectory()
    
    // PRIORITY 1: Check for local Claude installation (usually the newest version)
    // This is typically installed via the Claude installer, not npm
    let localClaudePath = "\(homeDir)/.claude/local"
    if FileManager.default.fileExists(atPath: localClaudePath) {
      // Insert at beginning for highest priority
      config.additionalPaths.insert(localClaudePath, at: 0)
    }
    // PRIORITY 2: Add essential system paths and common development tools
    // The SDK uses /bin/zsh -l -c which loads the user's shell environment,
    // so these are mainly fallbacks for tools installed in standard locations
    config.additionalPaths.append(contentsOf: [
      "/usr/local/bin",           // Homebrew on Intel Macs, common Unix tools
      "/opt/homebrew/bin",        // Homebrew on Apple Silicon
      "/usr/bin",                 // System binaries
      "\(homeDir)/.bun/bin",      // Bun JavaScript runtime
      "\(homeDir)/.deno/bin",     // Deno JavaScript runtime
      "\(homeDir)/.cargo/bin",    // Rust cargo
      "\(homeDir)/.local/bin"     // Python pip user installs
    ])
    
    return config
  }
  
  var body: some View {
    ClaudeCodeContainer(
      claudeCodeConfiguration: config,
      uiConfiguration: UIConfiguration(
        appName: "🫒live",
        showSettingsInNavBar: true,
        showRiskData: false,
        workingDirectoryToolTip: "Tip: Select a folder to enable AI assistance"))
    .background(colorScheme == .dark ? Color(hue: 0.361, saturation: 0.414, brightness: 0.05) : .clear)
  }

  @Environment(\.colorScheme) var colorScheme
}
