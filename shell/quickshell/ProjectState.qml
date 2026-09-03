import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    property var projects: []

    function refresh(): void {
        if (!scanProc.running)
            scanProc.running = true;
    }

    function openTerminal(path: string): void {
        actionProc.command = ["foot", "-D", path];
        actionProc.running = true;
    }

    function openFiles(path: string): void {
        actionProc.command = ["nautilus", path];
        actionProc.running = true;
    }

    function openCode(path: string): void {
        actionProc.command = ["sh", "-lc", "command -v code >/dev/null 2>&1 && exec code " + JSON.stringify(path) + " || exec foot -D " + JSON.stringify(path)];
        actionProc.running = true;
    }

    Process {
        id: scanProc
        command: ["sh", "-lc", "for root in \"$HOME/Code\" \"$HOME/Projects\" \"$HOME/Dev\" /mnt; do [ -d \"$root\" ] || continue; find \"$root\" -maxdepth 3 -type d -name .git -print 2>/dev/null; done | sed 's#/.git$##' | sort -u | head -40"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const rows = text.trim().length > 0 ? text.trim().split("\n") : [];
                root.projects = rows.map(path => {
                    const pieces = path.split("/");
                    return { name: pieces[pieces.length - 1], path: path };
                });
            }
        }
    }

    Process { id: actionProc }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
