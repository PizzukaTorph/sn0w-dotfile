import Quickshell.Io
import QtQuick

Item {
    id: root

    required property var settingsState
    property var projects: []
    property var activeProject: null
    property string activePath: ""
    property string activeService: ""
    property string actionStatus: ""
    property string lastError: ""
    property var doctorResults: ({})

    function updateActiveProject(): void {
        let selected = null
        let selectedUpdatedAt = -1

        for (let i = 0; i < projects.length; ++i) {
            const project = projects[i]
            if (!project.session || project.session.running !== true)
                continue

            const updatedAt = project.session.updatedAt || 0
            if (selected === null || updatedAt >= selectedUpdatedAt) {
                selected = project
                selectedUpdatedAt = updatedAt
            }
        }

        activeProject = selected
    }

    function refresh(): void {
        if (scanProc.running)
            return

        scanProc.command = [
            "python3",
            "-c",
            "import json,os,subprocess,sys; roots=json.loads(sys.argv[1]); out=[]; seen=set();\nfor raw in roots:\n root=os.path.abspath(os.path.expanduser(raw));\n if not os.path.isdir(root): continue\n base=root.rstrip(os.sep).count(os.sep)\n for d,dirs,files in os.walk(root):\n  depth=d.rstrip(os.sep).count(os.sep)-base\n  if '.git' in dirs and d not in seen:\n   seen.add(d);\n   try:\n    p=subprocess.run(['sn0w-project','status',d],capture_output=True,text=True,timeout=3); out.append(json.loads(p.stdout) if p.returncode==0 and p.stdout.strip() else {'name':os.path.basename(d),'path':d})\n   except Exception: out.append({'name':os.path.basename(d),'path':d})\n   dirs.remove('.git')\n   if len(out)>=40: break\n  if depth>=3: dirs[:]=[]\n if len(out)>=40: break\nprint(json.dumps(sorted(out,key=lambda x:x.get('name','').lower())))",
            JSON.stringify(settingsState.projectRoots)
        ]
        scanProc.running = true
    }

    function runSession(action: string, path: string): void {
        if (actionProc.running)
            return

        activePath = path
        activeService = ""
        lastError = ""
        if (action === "stop")
            actionStatus = "Stopping…"
        else if (action === "resume")
            actionStatus = "Resuming…"
        else
            actionStatus = "Starting…"
        actionProc.command = ["sn0w-project", action, path]
        actionProc.running = true
    }

    function startProject(path: string): void {
        runSession("start", path)
    }

    function resumeProject(path: string): void {
        runSession("resume", path)
    }

    function stopProject(path: string): void {
        runSession("stop", path)
    }

    function doctorProject(path: string): void {
        if (doctorProc.running)
            return
        activePath = path
        lastError = ""
        actionStatus = "Checking…"
        doctorProc.command = ["sn0w-project", "doctor", path]
        doctorProc.running = true
    }

    function restartService(path: string, service: string): void {
        if (actionProc.running)
            return

        activePath = path
        activeService = service
        lastError = ""
        actionStatus = "Restarting " + service + "…"
        actionProc.command = ["sn0w-project", "service-restart", path, service]
        actionProc.running = true
    }

    function openServiceLogs(path: string, service: string): void {
        launchProc.command = [
            "sn0w-project",
            "service-logs",
            path,
            service,
            "--terminal",
            settingsState.terminal
        ]
        launchProc.running = true
    }

    function execService(path: string, service: string): void {
        launchProc.command = [
            "sn0w-project",
            "service-exec",
            path,
            service,
            "--terminal",
            settingsState.terminal
        ]
        launchProc.running = true
    }

    function openService(path: string, service: string): void {
        launchProc.command = ["sn0w-project", "service-open", path, service]
        launchProc.running = true
    }

    function openTerminal(path: string): void {
        launchProc.command = ["sh", "-lc", "cd " + JSON.stringify(path) + " && exec " + settingsState.terminal]
        launchProc.running = true
    }

    function openFiles(path: string): void {
        launchProc.command = [settingsState.fileManager, path]
        launchProc.running = true
    }

    function openCode(path: string): void {
        if (settingsState.editor.trim().length > 0)
            launchProc.command = [settingsState.editor, path]
        else
            launchProc.command = ["sh", "-lc", "cd " + JSON.stringify(path) + " && exec " + settingsState.terminal]
        launchProc.running = true
    }

    Process {
        id: scanProc

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.projects = text.trim().length > 0 ? JSON.parse(text) : []
                } catch (e) {
                    root.projects = []
                }
                root.updateActiveProject()
            }
        }
    }

    Process {
        id: actionProc

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0)
                    root.lastError = text.trim()
            }
        }

        onRunningChanged: {
            if (!running) {
                root.actionStatus = root.lastError.length > 0 ? "Action failed" : ""
                root.activePath = ""
                root.activeService = ""
                refreshTimer.restart()
                if (root.lastError.length > 0)
                    clearStatusTimer.restart()
            }
        }
    }

    Process {
        id: doctorProc

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(text)
                    const path = result.project && result.project.path ? result.project.path : root.activePath
                    const next = Object.assign({}, root.doctorResults)
                    next[path] = result.checks || {}
                    root.doctorResults = next
                } catch (e) {
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0)
                    root.lastError = text.trim()
            }
        }

        onRunningChanged: {
            if (!running) {
                root.actionStatus = root.lastError.length > 0 ? "Check failed" : ""
                root.activePath = ""
                refreshTimer.restart()
                clearStatusTimer.restart()
            }
        }
    }

    Process {
        id: launchProc
    }

    Timer {
        id: refreshTimer
        interval: 500
        repeat: false
        onTriggered: root.refresh()
    }

    Timer {
        id: clearStatusTimer
        interval: 3500
        repeat: false
        onTriggered: {
            root.actionStatus = ""
            root.lastError = ""
        }
    }

    Timer {
        interval: 8000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: root.refresh()
}
