# Quickshell

This directory will contain the sn0w shell implementation.

Planned modules:

```text
quickshell/
├── topbar/
├── control-center/
├── launcher/
├── app-switcher/
├── overview/
├── notifications/
├── osd/
├── clipboard/
├── capture/
├── project-center/
├── containers/
├── settings/
└── common/
```

Keep backend ownership outside Quickshell. Quickshell asks NetworkManager, PipeWire, Docker, Hyprland and other owners for state/actions; it does not become their replacement.
