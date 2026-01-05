# AGENTS.md - TmuxMenuBar

This document provides guidelines for AI coding agents working on this repository.

## Project Overview

TmuxMenuBar is a lightweight macOS menu bar application for monitoring and managing tmux sessions. Built with Swift and SwiftUI, it runs as a menu bar-only app (no dock icon).

**Tech Stack:**
- Swift 5.9+
- SwiftUI with `MenuBarExtra` API
- macOS 14.0+ (Sonoma)
- Swift Package Manager (no Xcode project required)

## Build Commands

```bash
# Build release and create .app bundle
make build

# Build and run the app
make run

# Install to /Applications
make install

# Clean build artifacts
make clean

# Debug build only (no .app bundle)
swift build

# Release build only (no .app bundle)
swift build -c release
```

## Project Structure

```
tmux-menubar/
├── Sources/TmuxMenuBar/
│   ├── TmuxMenuBarApp.swift    # Main app, UI components, state
│   └── TmuxService.swift       # Shell command execution for tmux
├── Resources/
│   └── Info.plist              # App bundle configuration
├── Package.swift               # Swift package manifest
├── Makefile                    # Build automation
└── .github/workflows/ci.yml    # CI/CD pipeline
```

## Code Style Guidelines

### Imports

- Import only what you need
- `Foundation` for non-UI code (TmuxService)
- `SwiftUI` for UI code (includes Foundation)
- Order: System frameworks first, then local modules

### Formatting

- **Indentation:** 4 spaces (Swift standard)
- **Line length:** ~100 characters soft limit
- **Braces:** Same line for opening brace
- **Trailing commas:** Not used

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Types/Classes | PascalCase | `AppState`, `TmuxService` |
| Functions/Methods | camelCase | `listSessions()`, `killSession(_:)` |
| Variables/Properties | camelCase | `selectedSession`, `logContent` |

### Types

- Use `struct` for services and data (prefer value types)
- Use `final class` with `@Observable` for state management
- Prefer `[String]` over `Array<String>`
- Use optionals (`String?`) rather than empty sentinels

### Error Handling

- Use `do/catch` for operations that can throw
- Return empty values (empty string, empty array) for recoverable failures
- Silence stderr for shell commands when errors are expected

### Documentation

- Use `///` doc comments for public functions
- Use `//` for inline implementation notes
- Use `// MARK: -` for section separators

### Shell Command Execution

Use `Process` with `/usr/bin/env` for portability:

```swift
process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
process.arguments = ["command", "arg1", "arg2"]
process.standardOutput = pipe
process.standardError = FileHandle.nullDevice  // Silence errors
```

## Architecture Guidelines

- **TmuxService:** Pure shell command execution, no UI knowledge
- **AppState:** Observable state container, business logic
- **Views:** Pure UI, delegate actions to AppState

### Timer-Based Updates

- Use `Timer.scheduledTimer` in state classes
- Always dispatch to main queue for UI updates
- Use reasonable intervals (1s for logs, 3s for session list)

## CI/CD

GitHub Actions workflow (`.github/workflows/ci.yml`):
- Triggers on push/PR to `main` and on tags `v*`
- Builds debug and release configurations
- Creates GitHub release with zipped .app on tags

To create a release:
```bash
git tag v1.0.0
git push origin v1.0.0
```

## Common Tasks

### Adding a new tmux command

1. Add method to `TmuxService.swift`
2. Call the private `run()` helper with tmux arguments
3. Return appropriate type (String, [String], or Void)

### Adding UI features

1. Add state properties to `AppState` if needed
2. Add methods to `AppState` for actions
3. Update `MenuContentView` or create new View structs
4. Keep views small and focused

### Debugging

```bash
# Run app directly to see stdout/stderr
./TmuxMenuBar.app/Contents/MacOS/TmuxMenuBar

# Check if tmux is available
which tmux

# List tmux sessions manually
tmux list-sessions -F "#{session_name}"
```
