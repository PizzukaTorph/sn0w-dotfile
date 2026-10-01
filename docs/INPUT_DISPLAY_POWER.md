# Input, Display & Power

These are daily-driver-critical subsystems. Reliability comes before visual polish.

## Input

- Command/SUPER: application modifier
- Option/ALT: quick actions
- Ctrl: Unix control modifier
- tap-to-click
- natural scrolling
- tuned pointer acceleration
- per-device handling where necessary

Target gestures:
- 3-finger left/right: workspace navigation
- 3-finger up: Overview
- 3-finger down: close Overview

## Display

Use Hyprland as source of truth for outputs. sn0w adds named profiles and a user-facing settings/control layer.

Initial profile concepts: Laptop, Desk, Presentation, TV.

Control Center exposes only quick switching/brightness; Settings handles arrangement and persistence.

## Power

Profiles: Performance, Balanced, Battery.

Precedence: manual override > workspace recommendation > system default.

Initial configurable battery policy candidate: dim 5m, display off 10m, suspend 20m, lid close suspend. Validate all actions on actual Asahi hardware before enabling by default.
