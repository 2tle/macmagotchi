<p align="center">
  <img src="docs/logo.svg" width="128" alt="Macmagotchi pixel cat logo">
</p>

<h1 align="center">Macmagotchi</h1>

<p align="center">A virtual pixel pet for your macOS menu bar.</p>

## Description

Macmagotchi is a small menu bar pet that stays out of your way. Check on it, feed it, play with it, let it sleep, or pet it while you work. It can also walk along the bottom of your desktop.

- **Requires:** macOS 14+
- **Built with:** Swift 6, SwiftUI, AppKit
- **Data:** `~/Library/Application Support/Macmagotchi/pet.json`

## Build

### Xcode

1. Open `Macmagotchi.xcodeproj`.
2. Select the **Macmagotchi** target.
3. Press <kbd>⌘R</kbd>.

### Swift Package Manager

```bash
swift build
swift run
```

## Features

- Choose a cat, rabbit, or bear.
- Track hunger, mood, energy, and affection.
- Feed, play, sleep, and pet through configurable focus timers.
- Grow your pet through affection levels.
- View pixel-art animations in the menu bar, popover, and optional desktop pet mode.
- Use English or Korean, select a theme, and reset pet data.
- Receive notifications when your pet needs attention.
