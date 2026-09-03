import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    id: root

    property bool launcherVisible: false
    property bool controlCenterVisible: false
    property bool powerMenuVisible: false
    property string mode: "General"

    function closeTransientSurfaces(): void {
        launcherVisible = false;
        controlCenterVisible = false;
        powerMenuVisible = false;
    }

    TopBar {
        mode: root.mode
        onLauncherRequested: {
            root.controlCenterVisible = false;
            root.powerMenuVisible = false;
            root.launcherVisible = !root.launcherVisible;
        }
        onControlCenterRequested: {
            root.launcherVisible = false;
            root.powerMenuVisible = false;
            root.controlCenterVisible = !root.controlCenterVisible;
        }
        onPowerRequested: {
            root.launcherVisible = false;
            root.controlCenterVisible = false;
            root.powerMenuVisible = !root.powerMenuVisible;
        }
    }

    Launcher {
        visible: root.launcherVisible
    }

    ControlCenter {
        visible: root.controlCenterVisible
    }

    PowerMenu {
        visible: root.powerMenuVisible
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.controlCenterVisible = false;
            root.powerMenuVisible = false;
            root.launcherVisible = !root.launcherVisible;
        }

        function open(): void {
            root.closeTransientSurfaces();
            root.launcherVisible = true;
        }

        function close(): void {
            root.launcherVisible = false;
        }
    }

    IpcHandler {
        target: "controlcenter"

        function toggle(): void {
            root.launcherVisible = false;
            root.powerMenuVisible = false;
            root.controlCenterVisible = !root.controlCenterVisible;
        }

        function open(): void {
            root.closeTransientSurfaces();
            root.controlCenterVisible = true;
        }

        function close(): void {
            root.controlCenterVisible = false;
        }
    }

    IpcHandler {
        target: "power"

        function toggle(): void {
            root.launcherVisible = false;
            root.controlCenterVisible = false;
            root.powerMenuVisible = !root.powerMenuVisible;
        }

        function close(): void {
            root.powerMenuVisible = false;
        }
    }

    IpcHandler {
        target: "shell"

        function close(): void {
            root.closeTransientSurfaces();
        }

        function setMode(value: string): void {
            root.mode = value;
        }
    }
}
