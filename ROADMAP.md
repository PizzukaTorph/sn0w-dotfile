# sn0w Roadmap

## Phase 0 — Foundation

- [x] Define architecture and UX principles
- [x] Choose Fedora Asahi Minimal
- [x] Choose Hyprland
- [x] Choose Quickshell
- [x] Choose Nautilus
- [x] Choose Ghostty + zsh + Oh My Zsh
- [x] Define Context Workspace / Project Session model
- [ ] Verify exact Fedora Asahi package names and repositories on target machine
- [ ] Create bootstrap script with dry-run / idempotent behaviour

## Phase 1 — Bootable daily-driver skeleton

- [ ] Hyprland session boots cleanly
- [ ] Quickshell minimal process starts reliably
- [ ] Ghostty shortcut works
- [ ] Nautilus + GVFS/udisks/keyring integration works
- [ ] PipeWire audio works
- [ ] Wi-Fi + Bluetooth work
- [ ] portals + screen sharing/file pickers work
- [ ] lock / idle / suspend / lid lifecycle tested

## Phase 2 — Input / Display / Power

- [ ] Apple keyboard modifier policy
- [ ] per-app/macOS-like shortcuts where needed
- [ ] trackpad tap/natural scroll/acceleration
- [ ] 3-finger workspace gestures
- [ ] Overview gesture plumbing
- [ ] internal Retina scaling verified
- [ ] external monitor hotplug verified
- [ ] display profiles
- [ ] power profiles + precedence model
- [ ] battery/AC idle policy

## Phase 3 — Core sn0w Shell

- [ ] topbar
- [ ] Control Center
- [ ] audio/brightness OSD
- [ ] transient notifications
- [ ] power menu
- [ ] calendar
- [ ] launcher V1 (.desktop + fuzzy search)
- [ ] app switcher
- [ ] clipboard history
- [ ] screenshot V1

## Phase 4 — Context Workspaces & Overview

- [ ] General workspace semantics
- [ ] Project workspace semantics
- [ ] Activity workspace/profile schema
- [ ] Overview workspace cards
- [ ] Overview keyboard search
- [ ] project/activity contextual topbar state
- [ ] window movement/association where cleanly supported

## Phase 5 — Project Center

- [ ] project manifest schema
- [ ] project discovery/registry
- [ ] Project Session lifecycle
- [ ] dynamic workspace assignment
- [ ] Git status surface
- [ ] Compose/service state
- [ ] Code / Terminal / Browser actions
- [ ] Logs / Exec
- [ ] HTTP port Open actions
- [ ] prevent duplicate active sessions

## Phase 6 — Containers panel

- [ ] container list + status/health
- [ ] ports
- [ ] Compose grouping
- [ ] start/stop/restart
- [ ] Ghostty Logs
- [ ] Ghostty Exec with bash -> sh fallback
- [ ] lightweight CPU/RAM

## Phase 7 — Settings & polish

- [ ] sn0w Settings shell
- [ ] Appearance
- [ ] Keyboard/Shortcuts
- [ ] Displays
- [ ] Sound
- [ ] Power
- [ ] Network/Bluetooth
- [ ] Trackpad
- [ ] Containers
- [ ] About
- [ ] coherent GTK/Qt/icon/cursor/font strategy
- [ ] Quick Look
- [ ] screen recording UI

## Phase 8 — Sessions & recovery

- [ ] session persistence model
- [ ] Resume / Windows only / Dismiss prompt
- [ ] safe restoration of project associations
- [ ] backup/export of local state
- [ ] recovery documentation

## Definition of daily-driver ready

sn0w is daily-driver ready when suspend/resume, lid close, Wi-Fi, Bluetooth, audio, portals, display hotplug, input, lock, browser/IDE/terminal workflows and upgrades have been tested for a sustained period without requiring macOS as a fallback for normal development work.
