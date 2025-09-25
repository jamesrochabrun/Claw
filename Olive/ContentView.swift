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
    
    // PRIORITY 2: Check if user has manually specified Claude path (override everything)
    let prefs = UserDefaults.standard
    if let claudePath = prefs.string(forKey: "global.claudePath"),
       !claudePath.isEmpty,
       FileManager.default.fileExists(atPath: claudePath) {
      let url = URL(fileURLWithPath: claudePath)
      let directory = url.deletingLastPathComponent().path
      // Insert at beginning for absolute highest priority
      config.additionalPaths.insert(directory, at: 0)
    }
    
    // PRIORITY 3: Add essential system paths and common development tools
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
        appName: "Olive",
        showSettingsInNavBar: true,
        showRiskData: false,
        workingDirectoryToolTip: "Tip: Select a folder to enable AI assistance"))
  }
}

#Preview {
  ContentView()
}
