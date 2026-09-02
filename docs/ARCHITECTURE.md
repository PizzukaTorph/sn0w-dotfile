# Architecture

## Ownership boundaries

| Concern | Owner | sn0w role |
|---|---|---|
| Apple Silicon hardware enablement | Fedora Asahi | consume, do not fork |
| Compositing / windows / workspaces | Hyprland | configure + add semantics |
| Shell UX | Quickshell | primary UI layer |
| Files | Nautilus/GVFS/udisks2 | surface shortcuts/context |
| Audio | PipeWire | control frontend |
| Networking | NetworkManager | control frontend |
| Containers | Docker | operational frontend |
| Git | git | status/actions only |
| Secrets | keyring/agent | integrate, never replace |
| Terminal | Ghostty | launch/context integration |
| Editor | VS Code initially | launch/context integration |

## Navigation contract

- Launcher: **What do I want to do?**
- Overview: **Where am I working?**
- Project Center: **How is what I am working on?**
- Control Center: **How is the machine?**

These surfaces must not collapse into one mega-dashboard.

## State model

```text
Workspace
├── General
├── Project ── Project Session ── Project
└── Activity ── Activity Profile

Project Session
├── Hyprland workspace
├── associated windows
├── terminals
├── services/containers
└── URLs/actions
```

The shell may cache derived state, but authoritative state remains with the owning backend whenever possible.
