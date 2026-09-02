# sn0w — Specification

## 1. Vision

sn0w is a personal, developer-first Linux workstation shell for a MacBook Pro M1 Pro (32 GB), with macOS retained mainly for backup, audio recording and audio production.

Fedora Asahi Minimal is the hardware-enablement foundation. Fedora should largely disappear from the daily user experience.

**Core rule:** sn0w surfaces information and actions; it does not replace the tools that own them.

## 2. Core stack

- Base OS: Fedora Asahi Minimal
- Compositor/window manager: Hyprland
- Shell/UI: Quickshell
- File manager: Nautilus
- Terminal: Ghostty
- Shell: zsh + Oh My Zsh
- Audio backend: PipeWire
- Network backend: NetworkManager
- Containers: Docker initially; UI must remain conceptually backend-thin
- Secrets/keyring: mature Linux keyring, likely gnome-keyring where useful
- Storage integration: GVFS + udisks2 where appropriate

## 3. UX principles

- macOS-like ergonomics where they improve muscle memory; not a visual clone.
- Command/SUPER is the primary application modifier.
- Option/ALT is used for quick actions and launch shortcuts.
- Ctrl remains real Unix Ctrl, especially in terminals.
- Keyboard-first, trackpad-friendly, mouse-optional.
- Quickshell is a coherent frontend over mature Linux services, not a new OS service layer.

### Key conventions

- ⌘C/V/X/Z/A/F: application actions
- ⌘W/T/L: standard application/tab/location actions
- Ctrl+C/D/Z: Unix semantics in terminals
- ⇧⌥T: Ghostty
- ⇧⌥V: VS Code
- ⌘Space: launcher / command palette
- ⌘Tab: app switcher
- ⌘`: cycle windows of the same app (target behaviour)
- ⌘↑: Overview (target shortcut)
- ⌘⌥D: Containers panel (candidate)

## 4. Shell responsibilities

Quickshell provides:

- Mac-like topbar
- Control Center
- OSDs for volume/brightness
- ephemeral notification toasts
- launcher / command palette
- app switcher
- calendar
- power menu
- Overview
- clipboard history UI
- screenshot/recording UI
- sn0w Settings
- Project Center
- Containers panel

No Notification Center/history is required in V1; notifications are transient toasts, except genuinely urgent notifications may remain until dismissed.

## 5. Topbar

The topbar is context-aware. It should remain visually restrained.

Neutral/General context: active app/window, clock, connectivity, audio, battery and shell affordances.

Project context: may additionally surface project name, Git branch/cleanliness and compact service-health indicators.

Activity context: may surface relevant controls, e.g. media controls in Media or performance/DND state in Gaming.

## 6. Control Center

First-class component. It should expose fast actions, not become a monitoring dashboard.

V1 targets:

- Wi-Fi
- Bluetooth
- audio volume, mute, input/output selection
- brightness
- power profile
- Night Light if supported cleanly
- VPN/WireGuard
- Do Not Disturb
- battery status
- Settings shortcut
- Power actions

Keyboard accessibility is required.

## 7. File management

Nautilus is the primary file manager without installing the full GNOME desktop. Provide the supporting services required for a complete experience: GVFS, udisks2, keyring, portals, thumbnails/previews.

Quick Look target: Space on a selected file should open a fast preview. Prefer GNOME Sushi if it provides a clean solution; use a custom Quickshell overlay only if justified.

## 8. Terminal

Ghostty + zsh + Oh My Zsh.

Terminal UX must preserve Unix controls while supporting macOS muscle memory: ⌘C copies and ⌘V pastes; Ctrl+C remains SIGINT.

## 9. Launcher and app switching

### Launcher

⌘Space opens a Quickshell launcher inspired by Spotlight/Raycast.

V1:
- enumerate .desktop applications
- fuzzy search
- icons
- launch application

Later:
- commands
- recent files
- projects
- SSH targets
- calculations
- system actions

### App switcher

⌘Tab opens a Quickshell app switcher grouped by application rather than blindly listing windows. Target behaviour: ⌘` cycles windows within the current application.

## 10. Context Workspace model

A Workspace is a visual Hyprland workspace with semantics added by sn0w.

Types:

- **General**: neutral/manual workspace for transient work.
- **Project**: dynamically associated with an active Project Session.
- **Activity**: optional recreational or non-development context such as Media, Gaming or Social.

Do not pre-create many Activity workspaces. The model supports them; the user defines only useful ones.

Activity profiles can define name, icon, preferred apps/URLs/actions and persistence policy. Context may influence shell presentation and safe recommendations (for example Gaming can recommend Performance + DND), but manual user overrides always win.

## 11. Overview

Overview answers: **Where am I working?**

It must not duplicate Project Center.

Target interactions:
- 3-finger up: open Overview
- 3-finger down: close Overview
- 3-finger left/right: previous/next workspace
- click workspace: enter
- click window: enter + focus
- drag window between workspaces where technically clean
- ⌘↑: open Overview
- typing while Overview is open performs contextual search without a permanently visible search box

Project workspace cards may show only compact project state (name, branch, health). Inactive projects may appear as a subtle launch strip.

Live window thumbnails are optional: implement only if Hyprland/Wayland provides a clean path. A polished icon/title representation is preferable to fragile capture hacks.

## 12. Project Center

Project Center answers: **How is the thing I am working on?**

A Project is persistent configuration. A Project Session is the active runtime context.

A project may describe:
- filesystem path
- icon/name
- editor
- Compose configuration
- service URLs
- useful terminal working directories
- startup actions

V1 surface:
- project running/stopped state
- Git branch + clean/dirty state
- Compose/container state and health
- exposed ports and HTTP links
- Start / Stop / Restart
- Code
- Terminal
- Browser
- Logs
- Exec

Project Center must not reimplement Git clients, Docker Desktop or IDEs.

### Session semantics

When a project is selected from the launcher:
- if inactive, create/start a Project Session and assign a dynamic Project workspace
- if already active, focus its existing workspace; do not create duplicates

A Project Session can own/associate workspace, windows, terminals, containers/services and URLs.

Session restore may remember these relationships. On login, avoid blind resurrection: offer Resume / Windows only / Dismiss when applicable.

## 13. Containers panel

A lightweight Docker-Desktop-like operational panel, focused on daily actions.

Show:
- running/stopped containers
- health/status
- exposed ports
- CPU/RAM where cheap to obtain
- Compose project association

Actions:
- start / stop / restart
- Open for HTTP ports
- Logs -> Ghostty running `docker logs -f`
- Exec -> Ghostty running `docker exec -it`, prefer bash with sh fallback

Advanced Docker administration remains CLI/other tooling territory.

## 14. Clipboard, screenshots and OSD

Clipboard backend: wl-clipboard or equivalent. ⌘⇧V opens searchable history; support text and images where practical, plus pin/clear controls.

Screenshot conventions:
- ⌘⇧3: full screen
- ⌘⇧4: area selection
- ⌘⇧5: screenshot/recording UI

Use mature Wayland capture tools behind a Quickshell frontend. Result should be easy to copy and should produce a small preview toast.

## 15. Input

Priority: MacBook-quality daily-driver feel.

Baseline:
- tap-to-click
- natural scrolling
- tuned pointer acceleration
- internal Apple keyboard plus sane per-device handling for externals
- Command = SUPER, Option = ALT, Ctrl stays Ctrl

Gesture targets:
- 3-finger horizontal swipe: switch workspaces
- 3-finger up: Overview
- 3-finger down: close Overview

Avoid destructive gestures likely to trigger accidentally.

## 16. Display

Provide a thin display-profile layer over Hyprland.

Profiles may include:
- Laptop: internal only
- Desk: internal + external with saved arrangement
- Presentation: mirror
- TV: external-focused profile

Unknown displays should use safe preferred/automatic behaviour. sn0w Settings owns detailed arrangement; Control Center only exposes quick actions/profile switching.

## 17. Power

Daily-driver reliability beats aggressive tuning.

Profiles:
- Performance
- Balanced (default)
- Battery

Precedence rule: **manual override > workspace recommendation > system default**.

Suggested initial battery behaviour (configurable):
- dim after ~5 min
- display off after ~10 min
- suspend after ~20 min
- lid close -> suspend

AC timeouts can be more relaxed.

Expose only battery metrics the kernel/backend can report reliably.

## 18. Settings

sn0w Settings is a thin custom panel, not a GNOME Settings rewrite.

Target sections:
- Appearance
- Keyboard
- Shortcuts
- Displays
- Sound
- Power
- Network
- Bluetooth
- Trackpad
- Containers
- Shell
- About

Each section should delegate state changes to the real backend.

## 19. Dev environment

Keep the Fedora host relatively clean. Prefer project-local environments, devcontainers and/or Distrobox where useful.

The launcher/Project Center may orchestrate existing tools: start Compose, open VS Code, create/focus a project workspace, open browser URLs and terminals.

## 20. Network, SSH and secrets

Control Center exposes Wi-Fi/VPN state and useful host/IP information without becoming a network console.

Launcher can expose named SSH targets; selection opens Ghostty with the SSH command/profile.

Use mature SSH agent/keyring/Git credential infrastructure. Do not build custom secret storage.

## 21. Login, lock and lifecycle

Target lifecycle: login -> Hyprland -> Quickshell.

Lock, idle and suspend must rely on secure/mature components. A Quickshell-rendered lock UI is acceptable only if the security model remains correct; otherwise use Hyprlock or equivalent and theme it coherently.

## 22. Reproducibility

The repository is the source of truth for sn0w. A fresh Fedora Asahi Minimal install should eventually be transformable into sn0w through a documented/bootstrap process.

Do not add speculative configuration merely to make the tree look complete. Every active config should correspond to a verified dependency and tested behaviour.
