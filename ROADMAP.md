# sn0w Roadmap

## Milestone 0 — Specification

- [x] Fedora Asahi Minimal as hardware/base layer
- [x] Hyprland compositor
- [x] Quickshell shell
- [x] Ghostty + zsh/Oh My Zsh
- [x] Nautilus file manager
- [x] macOS-like modifier contract
- [x] Context Workspace model
- [x] Project / Project Session distinction
- [x] Project Center architecture
- [x] Overview / Mission Control concept
- [x] Control Center concept
- [x] Input / display / power baseline

## Milestone 1 — Reproducible VM prototype

- [x] Ansible provisioning architecture
- [x] vm/asahi profile split
- [x] minimal bootstrap script
- [x] initial package/service roles
- [x] dotfile linking model
- [ ] validate package names on target Fedora release
- [ ] boot generic Fedora VM on S0N
- [ ] run bootstrap from clean install
- [ ] reach Hyprland session
- [ ] make Quickshell V0 visible
- [ ] validate Ghostty and Nautilus
- [ ] validate PipeWire / NetworkManager integration

## Milestone 2 — Core shell

- [ ] topbar
- [ ] launcher
- [ ] app switcher
- [ ] toast notifications
- [ ] OSD
- [ ] Control Center
- [ ] clipboard history
- [ ] screenshot/record UI
- [ ] Quick Look

## Milestone 3 — Context workspaces

- [ ] General / Project / Activity semantic workspaces
- [ ] Overview
- [ ] project workspace allocation
- [ ] Activity profiles
- [ ] window/session association
- [ ] restore prompt

## Milestone 4 — Developer workstation

- [ ] Project manifest schema
- [ ] Project discovery
- [ ] Project Sessions
- [ ] Project Center
- [ ] Docker status/actions/logs/exec
- [ ] Git status/actions
- [ ] project Start / Stop orchestration
- [ ] SSH quick actions for remote hosts

## Milestone 5 — Physical sn0w / Asahi

- [ ] install Fedora Asahi Minimal on MacBook Pro M1 Pro
- [ ] run `./bootstrap.sh asahi`
- [ ] Apple keyboard modifier validation
- [ ] trackpad gesture tuning
- [ ] Retina/fractional scaling
- [ ] brightness + keyboard backlight
- [ ] speakers/audio validation
- [ ] Bluetooth validation
- [ ] lid close/open
- [ ] suspend/resume
- [ ] battery and power profiles
- [ ] external display profiles

## Milestone 6 — Daily-driver hardening

- [ ] login / lock lifecycle
- [ ] portal / screen sharing / file picker validation
- [ ] keyring / SSH agent / Git credentials
- [ ] MIME/default apps
- [ ] storage automount / SMB / SFTP
- [ ] update and recovery policy
- [ ] visual cohesion GTK/Qt/Electron
- [ ] clean reinstall test
