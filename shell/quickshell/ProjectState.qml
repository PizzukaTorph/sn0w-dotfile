import Quickshell.Io
import QtQuick

Item {
    id: root

    required property var settingsState
    property var projects: []

    function refresh(): void {
        if (scanProc.running)
            return

        scanProc.command = [
            "python3",
            "-c",
            "import json,os,sys; roots=json.loads(sys.argv[1]); out=[]; seen=set();\nfor raw in roots:\n root=os.path.abspath(os.path.expanduser(raw));\n if not os.path.isdir(root): continue\n base=root.rstrip(os.sep).count(os.sep)\n for d,dirs,files in os.walk(root):\n  depth=d.rstrip(os.sep).count(os.sep)-base\n  if '.git' in dirs and d not in seen:\n   seen.add(d); out.append(d); dirs.remove('.git')\n   if len(out)>=40: break\n  if depth>=3: dirs[:]=[]\n if len(out)>=40: break\nprint('\\n'.join(sorted(out)))",
            JSON.stringify(settingsState.projectRoots)
        ]
        scanProc.running = true
    }

    function openTerminal(path: string): void {
        actionProc.command = [
            "sh",
            "-lc",
            "cd " + JSON.stringify(path) + " && exec " + settingsState.terminal
        ]
        actionProc.running = true
    }

    function openFiles(path: string): void {
        actionProc.command = [settingsState.fileManager, path]
        actionProc.running = true
    }

    function openCode(path: string): void {
        if (settingsState.editor.trim().length > 0)
            actionProc.command = [settingsState.editor, path]
        else
            actionProc.command = ["sh", "-lc", "cd " + JSON.stringify(path) + " && exec " + settingsState.terminal]
        actionProc.running = true
    }

    Process {
        id: scanProc

        stdout: StdioCollector {
            onStreamFinished: {
                const rows = text.trim().length > 0 ? text.trim().split("\n") : []
                root.projects = rows.map(path => {
                    const pieces = path.split("/")
                    return {
                        name: pieces[pieces.length - 1],
                        path: path
                    }
                })
            }
        }
    }

    Process {
        id: actionProc
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: root.refresh()
}
