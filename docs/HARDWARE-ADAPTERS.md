# Hardware adapters

The Quickshell UI must not depend directly on Asahi-specific commands.

Logical providers:

```text
Quickshell
  -> sn0w adapters
       -> audio: PipeWire
       -> network: NetworkManager
       -> power: UPower / power-profiles-daemon
       -> display: Hyprland IPC
       -> containers: Docker
       -> hardware:
            generic-fedora
            apple-asahi
```

The `vm` profile may provide mock values for unavailable laptop hardware such as battery, lid state or keyboard backlight. The same UI components must consume the real providers on `asahi`.
