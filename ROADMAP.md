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
- [x] validate package names on Fedora 44 aarch64
- [x] run bootstrap from clean Fedora 44 aarch64 install
- [x] Quickshell package/runtime validation
- [x] Docker / Compose validation
- [x] document Mac UTM graphics limitation
- [ ] boot generic Fedora VM on S0N
- [ ] reach Hyprland graphical session on DRM/KMS-capable host
- [ ] make Quickshell V0 visible
- [ ] validate Ghostty and Nautilus
- [ ] validate PipeWire / NetworkManager integration

### Milestone 1A — ARM64 provisioning — COMPLETE

Fedora 44 aarch64 converges from a clean install with zero Ansible failures. Hyprland 0.56.x, Fedora Quickshell 0.2.1 Qt rebuild, Docker, Compose and dotfile links are installed reproducibly.

Apple Virtualization Framework in the current UTM test environment exposes `zwp_linux_dmabuf_v1` v3 while the Hyprland/Aquamarine stack requests v4, causing backend creation to fail before a graphical Hyprland session starts. This is treated as a VM graphics limitation, not as a sn0w provisioning failure. Graphical development moves to S0N/KVM or physical Asahi hardware.

## Milestone 2 — Core shell

- [x] Quickshell V0 entrypoint
- [x] topbar V0
- [x] launcher V0 surface + IPC toggle
- [ ] launcher desktop-entry index + fuzzy search
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
