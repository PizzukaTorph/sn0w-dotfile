import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    id: root

    property bool launcherVisible: false
    property bool controlCenterVisible: false
    property bool powerMenuVisible: false
    property bool switcherVisible: false
    property bool overviewVisible: false
    property bool clipboardVisible: false
    property bool captureVisible: false
    property string mode: "General"

    function closeTransientSurfaces(): void {
        launcherVisible = false;
        controlCenterVisible = false;
        powerMenuVisible = false;
        switcherVisible = false;
        overviewVisible = false;
        clipboardVisible = false;
        captureVisible = false;
    }

    SystemState { id: systemState }
    HyprState { id: hyprState }
    OSD { id: osd }

    TopBar {
        mode: root.mode
        systemState: systemState
        onLauncherRequested: {
            root.closeTransientSurfaces();
            root.launcherVisible = true;
        }
        onControlCenterRequested: {
            const next = !root.controlCenterVisible;
            root.closeTransientSurfaces();
            root.controlCenterVisible = next;
        }
        onPowerRequested: {
            const next = !root.powerMenuVisible;
            root.closeTransientSurfaces();
            root.powerMenuVisible = next;
        }
    }

    Launcher { visible: root.launcherVisible }
    ControlCenter {
        visible: root.controlCenterVisible
        systemState: systemState
    }
    PowerMenu { visible: root.powerMenuVisible }
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
    ClipboardHistory { visible: root.clipboardVisible }
    CapturePanel { visible: root.captureVisible }

    IpcHandler {
        target: "launcher"
        function toggle(): void { const next = !root.launcherVisible; root.closeTransientSurfaces(); root.launcherVisible = next; }
        function open(): void { root.closeTransientSurfaces(); root.launcherVisible = true; }
        function close(): void { root.launcherVisible = false; }
    }

    IpcHandler {
        target: "switcher"
        function toggle(): void { const next = !root.switcherVisible; root.closeTransientSurfaces(); root.switcherVisible = next; hyprState.refresh(); }
        function open(): void { root.closeTransientSurfaces(); root.switcherVisible = true; hyprState.refresh(); appSwitcher.resetAndShow(); }
        function cycle(): void {
            if (!root.switcherVisible) {
                root.closeTransientSurfaces();
                root.switcherVisible = true;
                hyprState.refresh();
                appSwitcher.resetAndShow();
            } else {
                appSwitcher.cycle();
            }
        }
        function close(): void { root.switcherVisible = false; }
    }

    IpcHandler {
        target: "overview"
        function toggle(): void { const next = !root.overviewVisible; root.closeTransientSurfaces(); root.overviewVisible = next; hyprState.refresh(); }
        function open(): void { root.closeTransientSurfaces(); root.overviewVisible = true; hyprState.refresh(); }
        function close(): void { root.overviewVisible = false; }
    }

    IpcHandler {
        target: "controlcenter"
        function toggle(): void { const next = !root.controlCenterVisible; root.closeTransientSurfaces(); root.controlCenterVisible = next; }
        function open(): void { root.closeTransientSurfaces(); root.controlCenterVisible = true; }
        function close(): void { root.controlCenterVisible = false; }
    }

    IpcHandler {
        target: "power"
        function toggle(): void { const next = !root.powerMenuVisible; root.closeTransientSurfaces(); root.powerMenuVisible = next; }
        function close(): void { root.powerMenuVisible = false; }
    }

    IpcHandler {
        target: "clipboard"
        function toggle(): void { const next = !root.clipboardVisible; root.closeTransientSurfaces(); root.clipboardVisible = next; }
        function open(): void { root.closeTransientSurfaces(); root.clipboardVisible = true; }
        function close(): void { root.clipboardVisible = false; }
    }

    IpcHandler {
        target: "capture"
        function toggle(): void { const next = !root.captureVisible; root.closeTransientSurfaces(); root.captureVisible = next; }
        function open(): void { root.closeTransientSurfaces(); root.captureVisible = true; }
        function close(): void { root.captureVisible = false; }
    }

    IpcHandler {
        target: "osd"
        function volume(value: int): void { osd.showValue("volume", value, false); }
        function mute(value: int): void { osd.showValue("volume", value, true); }
        function brightness(value: int): void { osd.showValue("brightness", value, false); }
    }

    IpcHandler {
        target: "shell"
        function close(): void { root.closeTransientSurfaces(); }
        function setMode(value: string): void { root.mode = value; }
    }
}
