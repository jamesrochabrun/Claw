# Olive Agent Setup Documentation

## Overview
This macOS app implements an AI agent that monitors screen activity and processes user queries using Claude AI.

## Setup Requirements

### 1. App Entitlements Configuration
The following entitlements were configured in `Olive.entitlements`:

#### Removed Entitlements:
- **App Sandbox**: Set to `NO` (removed `com.apple.security.app-sandbox`)
  - Required for full system access and screen recording capabilities

#### Added Entitlements:
- **User Script Sandboxing**: Set to `NO` (`com.apple.security.app-sandbox.user-scripts`)
  - Allows execution of user scripts without sandbox restrictions

### 2. Privacy & Permissions
Added to `Info.plist`:
- **Screen Recording Permission** (`NSScreenCaptureUsageDescription`)
  - Description: "Olive needs screen recording permission to capture screenshots for AI analysis"

### 3. Dependencies
The following packages were added via Swift Package Manager:

1. **SwiftOpenAI**
   - Repository: https://github.com/jamesrochabrun/SwiftOpenAI
   - Purpose: Integration with OpenAI/Claude API for AI processing

### 4. Core Components

#### AgentService (`AgentService.swift`)
- Main service handling AI agent functionality
- Manages screenshot capture and processing
- Integrates with Claude API for query processing
- Handles tool execution (bash commands, file operations, etc.)

#### Models
- `Agent.swift`: Core agent model with tools and capabilities
- `AgentMode.swift`: Defines different agent operational modes
- `AgentQuery.swift`: Query model for agent interactions
- `AgentTool.swift`: Tool definitions and execution logic

#### Views
- `AgentDetailView.swift`: Main interface for agent interaction
- `AgentListView.swift`: List of available agents
- `OliveApp.swift`: Main app entry point

### 5. Key Features
- Screen capture and analysis
- Natural language query processing
- Tool execution (bash, file operations, web search)
- Real-time agent response streaming
- Markdown rendering for responses

### 6. Build & Run Instructions
1. Open `Olive.xcodeproj` in Xcode
2. Ensure signing team is configured
3. Build and run (⌘+R)
4. Grant screen recording permission when prompted
5. Configure API key in app settings

### 7. Important Notes
- The app requires macOS 14.0 or later
- Screen recording permission is essential for functionality
- API key for Claude/OpenAI must be configured before use
- App runs without sandbox to enable full system integration

## Troubleshooting
- If screen recording fails: Check System Preferences > Privacy & Security > Screen Recording
- If API calls fail: Verify API key configuration and network connectivity
- For permission issues: Ensure app is properly signed and notarized for distribution