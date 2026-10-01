import Quickshell.Io
import QtQuick

Item {
    id: root

    required property var hyprState
    property var workspaces: []
    property var activeWorkspace: null
    property string activeName: ""

    function refresh(): void {
        if (!listProc.running)
            listProc.running = true
    }

    function runAction(args): void {
        if (actionProc.running)
            return
        actionProc.command = ["sn0w-workspace"].concat(args)
        actionProc.running = true
    }

    function focusWorkspace(name: string): void {
        if (name.length > 0)
            runAction(["focus-name", name])
    }

    function ensureSlot(slot: int): void {
        runAction(["ensure", String(slot)])
    }

    function moveWindowToSlot(slot: int): void {
        runAction(["move-window", String(slot)])
    }

    function next(): void {
        runAction(["next"])
    }

    function previous(): void {
        runAction(["previous"])
    }

    Process {
        id: listProc
        command: ["sn0w-workspace", "list"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const value = text.trim().length > 0 ? JSON.parse(text) : {}
                    root.workspaces = value.workspaces || []
                    root.activeWorkspace = value.active || null
                    root.activeName = root.activeWorkspace ? String(root.activeWorkspace.name || "") : ""
                } catch (e) {
                    root.workspaces = []
                    root.activeWorkspace = null
                    root.activeName = ""
                }
            }
        }
    }

    Process {
        id: actionProc
        onRunningChanged: {
            if (!running) {
                root.hyprState.refresh()
                refreshTimer.restart()
            }
        }
    }

    Connections {
        target: root.hyprState

        function onWorkspacesChanged(): void {
            refreshTimer.restart()
        }

        function onActiveWorkspaceChanged(): void {
            refreshTimer.restart()
        }
    }

    Timer {
        id: refreshTimer
        interval: 180
        repeat: false
        onTriggered: root.refresh()
    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: root.refresh()
}
