# Tic Tac Move

A SwiftUI iOS game: classic 3x3 tic-tac-toe with a twist. Each player has
only 3 pieces. Once both players have placed all of theirs, turns move an
existing piece to an adjacent empty cell instead of placing a new one.

Reference: https://claude.ai/public/artifacts/c8934baf-41f3-4955-b3b5-cff0a0fc7d79

## Requirements

- Xcode 15+
- iOS 16+ deployment target

## Getting started

Open `TicTacMove.xcodeproj` in Xcode, select your development team under
Signing & Capabilities for the `TicTacMove` target, then Run or
Product > Archive.

## Project layout

- `TicTacMove/GameEngine.swift` — game rules and state (placing/moving phases, win detection)
- `TicTacMove/BoardView.swift` — the 3x3 grid UI
- `TicTacMove/ContentView.swift` — top-level screen (score, status, reset)
- `TicTacMove/TicTacMoveApp.swift` — app entry point
