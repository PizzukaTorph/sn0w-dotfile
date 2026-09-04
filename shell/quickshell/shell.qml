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
        mode: root.mode
        systemState: systemState
        onLauncherRequested: {
            root.closeTransientSurfaces()
            root.launcherVisible = true
        }
    }

    Launcher {
        visible: root.launcherVisible
        projectState: projectState
        settingsState: settingsState

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

    AppSwitcher {
        id: appSwitcher
        visible: root.switcherVisible
        hyprState: hyprState
        onVisibleChanged: root.switcherVisible = visible
    }

    Overview {
        visible: root.overviewVisible
        hyprState: hyprState
    }

    ProjectCenter {
        visible: root.projectCenterVisible
        projectState: projectState
    }

    SettingsWindow {
        visible: root.settingsVisible
        settingsState: settingsState
    }

    ClipboardHistory {
        visible: root.clipboardVisible
    }

    CapturePanel {
        visible: root.captureVisible
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
        }

        function open(): void {
            root.closeTransientSurfaces()
            root.switcherVisible = true
            hyprState.refresh()
            appSwitcher.resetAndShow()
        }

        function cycle(): void {
            if (!root.switcherVisible) {
                root.closeTransientSurfaces()
                root.switcherVisible = true
                hyprState.refresh()
                appSwitcher.resetAndShow()
            } else {
                appSwitcher.cycle()
            }
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
        }

        function open(): void {
            root.closeTransientSurfaces()
            root.overviewVisible = true
            hyprState.refresh()
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
