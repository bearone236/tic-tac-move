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

### Ads (AdMob) setup

The project shows an AdMob interstitial between rounds, but the SDK is not
bundled in this repo yet — add it once in Xcode:

1. File > Add Package Dependencies…
2. Paste `https://github.com/googleads/swift-package-manager-google-mobile-ads.git`
3. Add the `GoogleMobileAds` product to the `TicTacMove` target.

Until you do this, `AdManager.swift` / `TicTacMoveApp.swift` won't compile
(`import GoogleMobileAds` unresolved).

Before submitting to the App Store, replace the **test** IDs with your own
AdMob account's real IDs:

- `AdManager.swift` → `adUnitID` (interstitial ad unit ID)
- Project build settings → `INFOPLIST_KEY_GADApplicationIdentifier` (App ID)

Both currently hold Google's public test IDs, which always serve test ads
and are safe to leave in for development.

## Project layout

- `TicTacMove/GameEngine.swift` — game rules and state (placing/moving phases, win detection, CPU opponent)
- `TicTacMove/BoardView.swift` — the 3x3 grid UI, including the sliding-piece animation
- `TicTacMove/GameView.swift` — the gameplay screen (score, status, board, top bar)
- `TicTacMove/GameOverOverlay.swift` — the themed game-over card
- `TicTacMove/HomeView.swift` — the title screen and CPU / 2-player mode picker
- `TicTacMove/HowToPlayView.swift` — the rules screen
- `TicTacMove/AmbientBackground.swift` — the shared drifting-particle background
- `TicTacMove/Theme.swift` — shared colors
- `TicTacMove/SoundPlayer.swift` — sound effects and ambient BGM playback
- `TicTacMove/AdManager.swift` — AdMob interstitial loading/presentation
- `TicTacMove/TicTacMoveApp.swift` — app entry point
