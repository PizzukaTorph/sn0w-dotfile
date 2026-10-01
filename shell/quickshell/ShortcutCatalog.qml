import QtQuick

QtObject {
    id: root

    // Single source of truth for sn0w shortcut presentation.
    // Hyprland still owns the actual bindings; this catalog is intentionally
    // human-readable so the same data can later feed Settings and a full
    // shortcut overlay without duplicating labels in multiple QML surfaces.
    readonly property var quickGroups: [
        {
            title: "Navigate",
            items: [
                { keys: "⌘ Space", action: "Launcher toggle" },
                { keys: "⌘ Tab", action: "App switcher" },
                { keys: "⌘ ↑", action: "Overview" },
                { keys: "3 fingers ← / →", action: "Previous / next workspace" }
            ]
        },
        {
            title: "Workspaces",
            items: [
                { keys: "⌘ ⇧ 1 / 2 / 3", action: "Create / focus General slot" },
                { keys: "⌘ ⌃ ← / →", action: "Previous / next workspace" },
                { keys: "⌘ ⌃ ⇧ 1 / 2 / 3", action: "Move window to General slot" }
            ]
        },
        {
            title: "Daily",
            items: [
                { keys: "⇧ ⌥ T", action: "Terminal" },
                { keys: "⌘ E", action: "Files" },
                { keys: "⌘ ⇧ V", action: "Clipboard" },
                { keys: "⌘ W", action: "Close window" },
                { keys: "⌘ F", action: "Fullscreen" }
            ]
        }
    ]

    readonly property var allGroups: [
        {
            title: "Shell",
            items: [
                { keys: "⌘ Space", action: "Launcher" },
                { keys: "⌘ Tab", action: "App switcher" },
                { keys: "⌘ ↑", action: "Overview" },
                { keys: "⌘ ⌥ D", action: "Project Center" },
                { keys: "⌘ ,", action: "Settings" },
                { keys: "⌘ ⇧ V", action: "Clipboard" }
            ]
        },
        {
            title: "Workspaces",
            items: [
                { keys: "3 fingers ← / →", action: "Previous / next existing workspace" },
                { keys: "⌘ ⌃ ← / →", action: "Previous / next existing workspace" },
                { keys: "⌘ ⇧ 1 / 2 / 3", action: "Create / focus General slot" },
                { keys: "⌘ ⌃ ⇧ 1 / 2 / 3", action: "Move window to General slot" },
                { keys: "⌘ ⌃ ⇧ ← / →", action: "Move window to previous / next workspace" }
            ]
        },
        {
            title: "Windows",
            items: [
                { keys: "⌘ W", action: "Close window" },
                { keys: "⌘ F", action: "Toggle fullscreen" },
                { keys: "⌘ ⇧ F", action: "Toggle floating" },
                { keys: "⌘ ← / → / ↓", action: "Focus window" }
            ]
        },
        {
            title: "Apps",
            items: [
                { keys: "⇧ ⌥ T", action: "Terminal" },
                { keys: "⌘ E", action: "Files" }
            ]
        },
        {
            title: "Capture",
            items: [
                { keys: "⌘ ⇧ 3", action: "Full-screen screenshot" },
                { keys: "⌘ ⇧ 4", action: "Area screenshot" },
                { keys: "⌘ ⇧ 5", action: "Capture panel" }
            ]
        }
    ]
}
