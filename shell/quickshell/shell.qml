import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    id: root

    property bool launcherVisible: false
    property bool switcherVisible: false
    property bool overviewVisible: false
    property bool clipboardVisible: false
    property bool captureVisible: false
    property bool projectCenterVisible: false
    property bool settingsVisible: false
    property string mode: "General"

    function closeTransientSurfaces(): void {
        launcherVisible = false
        switcherVisible = false
        overviewVisible = false
        clipboardVisible = false
        captureVisible = false
        projectCenterVisible = false
        settingsVisible = false
    }

    function resetSwitcher(): void {
        Qt.callLater(function() {
            if (switcherLoader.item)
                switcherLoader.item.resetAndShow()
        })
    }

    SystemState {
        id: systemState
    }

    HyprState {
        id: hyprState
    }

    SettingsState {
        id: settingsState
    }

    ProjectState {
        id: projectState
        settingsState: settingsState
    }

    OSD {
        id: osd
    }

    Connections {
        target: settingsState

        function onSaved(): void {
            projectState.refresh()
        }
    }

    TopBar {
        mode: projectState.activeProject ? "Project" : root.mode
        systemState: systemState
        projectState: projectState

        onLauncherRequested: {
            root.closeTransientSurfaces()
            root.launcherVisible = true
        }

        onProjectCenterRequested: {
            root.closeTransientSurfaces()
            projectState.refresh()
            root.projectCenterVisible = true
        }
    }

    // Quickshell 0.2.x can leave hidden FloatingWindows alive but unable to
    // remap reliably. All transient shell dialogs therefore use the same
    // lifecycle: closing destroys the xdg-toplevel and reopening creates it.
    Loader {
        id: launcherLoader
        active: root.launcherVisible
        asynchronous: false

        sourceComponent: Component {
            Launcher {
                projectState: projectState
                settingsState: settingsState
                visible: true

                onCloseRequested: root.launcherVisible = false

                onProjectCenterRequested: {
                    root.closeTransientSurfaces()
                    projectState.refresh()
                    root.projectCenterVisible = true
                }

                onSettingsRequested: {
                    root.closeTransientSurfaces()
                    settingsState.load()
                    root.settingsVisible = true
                }
            }
        }
    }

    Loader {
        id: switcherLoader
        active: root.switcherVisible
        asynchronous: false

        sourceComponent: Component {
            AppSwitcher {
                hyprState: hyprState
                visible: true
                onCloseRequested: root.switcherVisible = false
                onVisibleChanged: {
                    if (!visible && root.switcherVisible)
                        root.switcherVisible = false
                }
            }
        }
    }

    Loader {
        id: overviewLoader
        active: root.overviewVisible
        asynchronous: false

        sourceComponent: Component {
            Overview {
                hyprState: hyprState
                projectState: projectState
                visible: true
                onCloseRequested: root.overviewVisible = false
            }
        }
    }

    Loader {
        id: projectCenterLoader
        active: root.projectCenterVisible
        asynchronous: false

        sourceComponent: Component {
            ProjectCenter {
                projectState: projectState
                visible: true
                onVisibleChanged: {
                    if (!visible && root.projectCenterVisible)
                        root.projectCenterVisible = false
                }
            }
        }
    }

    Loader {
        id: settingsLoader
        active: root.settingsVisible
        asynchronous: false

        sourceComponent: Component {
            SettingsWindow {
                settingsState: settingsState
                visible: true
                onVisibleChanged: {
                    if (!visible && root.settingsVisible)
                        root.settingsVisible = false
                }
            }
        }
    }

    Loader {
        id: clipboardLoader
        active: root.clipboardVisible
        asynchronous: false

        sourceComponent: Component {
            ClipboardHistory {
                visible: true
                onVisibleChanged: {
                    if (!visible && root.clipboardVisible)
                        root.clipboardVisible = false
                }
            }
        }
    }

    Loader {
        id: captureLoader
        active: root.captureVisible
        asynchronous: false

        sourceComponent: Component {
            CapturePanel {
                visible: true
                onVisibleChanged: {
                    if (!visible && root.captureVisible)
                        root.captureVisible = false
                }
            }
        }
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            const next = !root.launcherVisible
            root.closeTransientSurfaces()
            root.launcherVisible = next
        }

        function open(): void {
            root.closeTransientSurfaces()
            root.launcherVisible = true
        }

        function close(): void {
            root.launcherVisible = false
        }
    }

    IpcHandler {
        target: "switcher"

        function toggle(): void {
            const next = !root.switcherVisible
            root.closeTransientSurfaces()
            root.switcherVisible = next
            hyprState.refresh()
            if (next)
                root.resetSwitcher()
        }

        function open(): void {
            root.closeTransientSurfaces()
            root.switcherVisible = true
            hyprState.refresh()
            root.resetSwitcher()
        }

        function cycle(): void {
            if (!root.switcherVisible) {
                root.closeTransientSurfaces()
                root.switcherVisible = true
                hyprState.refresh()
                root.resetSwitcher()
            } else if (switcherLoader.item) {
                switcherLoader.item.cycle()
            }
        }

        function commit(): void {
            if (root.switcherVisible && switcherLoader.item)
                switcherLoader.item.commitSelection()
        }

        function close(): void {
            root.switcherVisible = false
        }
    }

    IpcHandler {
        target: "overview"

        function toggle(): void {
            const next = !root.overviewVisible
            root.closeTransientSurfaces()
            root.overviewVisible = next
            hyprState.refresh()
            projectState.refresh()
        }

        function open(): void {
            root.closeTransientSurfaces()
            root.overviewVisible = true
            hyprState.refresh()
            projectState.refresh()
        }

        function close(): void {
            root.overviewVisible = false
        }
    }

    IpcHandler {
        target: "projects"

        function toggle(): void {
            const next = !root.projectCenterVisible
            root.closeTransientSurfaces()
            projectState.refresh()
            root.projectCenterVisible = next
        }

        function open(): void {
            root.closeTransientSurfaces()
            projectState.refresh()
            root.projectCenterVisible = true
        }

        function close(): void {
            root.projectCenterVisible = false
        }
    }

    IpcHandler {
        target: "settings"

        function toggle(): void {
            const next = !root.settingsVisible
            root.closeTransientSurfaces()
            settingsState.load()
            root.settingsVisible = next
        }

        function open(): void {
            root.closeTransientSurfaces()
            settingsState.load()
            root.settingsVisible = true
        }

        function close(): void {
            root.settingsVisible = false
        }
    }

    IpcHandler {
        target: "clipboard"

        function toggle(): void {
            const next = !root.clipboardVisible
            root.closeTransientSurfaces()
            root.clipboardVisible = next
        }

        function open(): void {
            root.closeTransientSurfaces()
            root.clipboardVisible = true
        }

        function close(): void {
            root.clipboardVisible = false
        }
    }

    IpcHandler {
        target: "capture"

        function toggle(): void {
            const next = !root.captureVisible
            root.closeTransientSurfaces()
            root.captureVisible = next
        }

        function open(): void {
            root.closeTransientSurfaces()
            root.captureVisible = true
        }

        function close(): void {
            root.captureVisible = false
        }
    }

    IpcHandler {
        target: "osd"

        function volumeUp(): void {
            const value = Math.min(100, systemState.volume + 5)
            systemState.setVolume(value)
            osd.showValue("volume", value, false)
        }

        function volumeDown(): void {
            const value = Math.max(0, systemState.volume - 5)
            systemState.setVolume(value)
            osd.showValue("volume", value, false)
        }

        function muteToggle(): void {
            systemState.toggleMute()
            osd.showValue("volume", systemState.volume, !systemState.muted)
        }

        function brightnessUp(): void {
            if (systemState.brightness < 0)
                return

            const value = Math.min(100, systemState.brightness + 5)
            systemState.setBrightness(value)
            osd.showValue("brightness", value, false)
        }

        function brightnessDown(): void {
            if (systemState.brightness < 0)
                return

            const value = Math.max(1, systemState.brightness - 5)
            systemState.setBrightness(value)
            osd.showValue("brightness", value, false)
        }
    }

    IpcHandler {
        target: "shell"

        function close(): void {
            root.closeTransientSurfaces()
        }

        function setMode(value: string): void {
            root.mode = value
        }
    }
}
