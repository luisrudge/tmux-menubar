# TmuxMenuBar

A lightweight macOS menu bar app for monitoring and managing tmux sessions.

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
![Swift 5.9+](https://img.shields.io/badge/Swift-5.9%2B-orange)

## Features

- View all active tmux sessions from your menu bar
- Real-time scrollable log viewer (updates every second)
- Kill sessions with one click
- No dock icon - runs entirely in the menu bar

## Installation

### Download

1. Download `TmuxMenuBar.zip` from the [latest release](https://github.com/luisrudge/tmux-menubar/releases/latest)
2. Unzip and drag `TmuxMenuBar.app` to `/Applications`
3. Launch from Applications or Spotlight

### Build from source

```bash
git clone https://github.com/luisrudge/tmux-menubar.git
cd tmux-menubar
make build
make install  # Copies to /Applications
```

## Usage

1. Click the terminal icon in your menu bar
2. Select a session from the left panel to view its logs
3. Click "Kill" to terminate a session
4. Click "Quit" to close the app

## Requirements

- macOS 14.0 (Sonoma) or later
- [tmux](https://github.com/tmux/tmux) installed (`brew install tmux`)

## License

MIT
