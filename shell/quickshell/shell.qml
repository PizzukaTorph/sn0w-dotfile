import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    id: root

    property bool launcherVisible: false

    TopBar {}

    Launcher {
        visible: root.launcherVisible
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.launcherVisible = !root.launcherVisible;
        }

        function open(): void {
            root.launcherVisible = true;
        }

        function close(): void {
            root.launcherVisible = false;
        }
    }
}
