import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property var clients: []
    property var workspaces: []
    property int activeWorkspace: 1

    function refresh(): void {
        if (!clientsProc.running) clientsProc.running = true;
        if (!workspacesProc.running) workspacesProc.running = true;
        if (!activeWorkspaceProc.running) activeWorkspaceProc.running = true;
    }

    function focusClient(address: string): void {
        if (address.length === 0) return;
        actionProc.command = ["hyprctl", "dispatch", "focuswindow", "address:" + address];
        actionProc.running = true;
    }

    function focusWorkspace(id: int): void {
        actionProc.command = ["hyprctl", "dispatch", "workspace", String(id)];
        actionProc.running = true;
    }

    function isShellSurface(client): bool {
        const cls = String(client.class || "").toLowerCase();
        const initialClass = String(client.initialClass || "").toLowerCase();
        const title = String(client.title || "").toLowerCase();
        const initialTitle = String(client.initialTitle || "").toLowerCase();

        if (cls.indexOf("quickshell") >= 0 || initialClass.indexOf("quickshell") >= 0)
            return true;

        return title.indexOf("sn0w ") === 0 || initialTitle.indexOf("sn0w ") === 0;
    }

    Process {
        id: clientsProc
        command: ["hyprctl", "-j", "clients"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    root.clients = data.filter(c =>
                        c.mapped !== false
                        && c.hidden !== true
                        && !root.isShellSurface(c)
                    );
                } catch (e) {
                    root.clients = [];
                }
            }
        }
    }

    Process {
        id: workspacesProc
        command: ["hyprctl", "-j", "workspaces"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    data.sort((a, b) => a.id - b.id);
                    root.workspaces = data;
                } catch (e) {
                    root.workspaces = [];
                }
            }
        }
    }

    Process {
        id: activeWorkspaceProc
        command: ["hyprctl", "-j", "activeworkspace"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    root.activeWorkspace = data.id || 1;
                } catch (e) {
                    root.activeWorkspace = 1;
                }
            }
        }
    }

    Process {
        id: actionProc
        onRunningChanged: {
            if (!running) refreshTimer.restart();
        }
    }

    Timer {
        id: refreshTimer
        interval: 250
        onTriggered: root.refresh()
    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
