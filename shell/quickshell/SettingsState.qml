import Quickshell.Io
import QtQuick

Item {
    id: root

    property var projectRoots: ["~/Code", "~/Projects", "~/Dev", "/mnt"]
    property var sshHosts: ["m0ther", "s0n"]
    property string terminal: "foot"
    property string fileManager: "nautilus"
    property string editor: "code"
    property string screenshotsDir: "~/Pictures/Screenshots"
    property string recordingsDir: "~/Videos/Captures"
    property bool loaded: false
    property bool saving: false
    property string status: ""

    signal saved()
    signal saveFailed(string message)

    function load(): void {
        if (loadProc.running)
            loadProc.running = false
        loadProc.running = true
    }

    function save(): void {
        const data = {
            projects: {
                roots: projectRoots
            },
            ssh: {
                hosts: sshHosts
            },
            apps: {
                terminal: terminal,
                fileManager: fileManager,
                editor: editor
            },
            capture: {
                screenshotsDir: screenshotsDir,
                recordingsDir: recordingsDir
            }
        }

        const payload = JSON.stringify(data)
        saveProc.command = [
            "python3",
            "-c",
            "import json,os,sys,tempfile; p=os.path.expanduser('~/.config/sn0w/settings.json'); os.makedirs(os.path.dirname(p),exist_ok=True); d=json.loads(sys.argv[1]); fd,tmp=tempfile.mkstemp(prefix='.settings-',suffix='.json',dir=os.path.dirname(p)); f=os.fdopen(fd,'w'); json.dump(d,f,indent=2); f.write('\\n'); f.close(); os.replace(tmp,p); print(p)",
            payload
        ]

        status = "Saving…"
        saving = true
        if (saveProc.running)
            saveProc.running = false
        saveProc.running = true
    }

    function addProjectRoot(value: string): void {
        const clean = value.trim()
        if (clean.length === 0)
            return
        if (projectRoots.indexOf(clean) >= 0)
            return
        const next = projectRoots.slice()
        next.push(clean)
        projectRoots = next
        save()
    }

    function removeProjectRoot(index: int): void {
        const next = projectRoots.slice()
        if (index < 0 || index >= next.length)
            return
        next.splice(index, 1)
        projectRoots = next
        save()
    }

    function addSshHost(value: string): void {
        const clean = value.trim()
        if (clean.length === 0)
            return
        if (sshHosts.indexOf(clean) >= 0)
            return
        const next = sshHosts.slice()
        next.push(clean)
        sshHosts = next
        save()
    }

    function removeSshHost(index: int): void {
        const next = sshHosts.slice()
        if (index < 0 || index >= next.length)
            return
        next.splice(index, 1)
        sshHosts = next
        save()
    }

    Process {
        id: loadProc
        command: [
            "python3",
            "-c",
            "import json,os; p=os.path.expanduser('~/.config/sn0w/settings.json'); d={'projects':{'roots':['~/Code','~/Projects','~/Dev','/mnt']},'ssh':{'hosts':['m0ther','s0n']},'apps':{'terminal':'foot','fileManager':'nautilus','editor':'code'},'capture':{'screenshotsDir':'~/Pictures/Screenshots','recordingsDir':'~/Videos/Captures'}}; os.makedirs(os.path.dirname(p),exist_ok=True);\nif os.path.exists(p):\n  try:\n    u=json.load(open(p));\n    for k,v in u.items():\n      if isinstance(v,dict) and isinstance(d.get(k),dict): d[k].update(v)\n      else: d[k]=v\n  except Exception: pass\nelse:\n  json.dump(d,open(p,'w'),indent=2)\nprint(json.dumps(d))"
        ]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text)
                    root.projectRoots = data.projects && data.projects.roots ? data.projects.roots : root.projectRoots
                    root.sshHosts = data.ssh && data.ssh.hosts ? data.ssh.hosts : root.sshHosts
                    root.terminal = data.apps && data.apps.terminal ? data.apps.terminal : root.terminal
                    root.fileManager = data.apps && data.apps.fileManager ? data.apps.fileManager : root.fileManager
                    root.editor = data.apps && data.apps.editor ? data.apps.editor : root.editor
                    root.screenshotsDir = data.capture && data.capture.screenshotsDir ? data.capture.screenshotsDir : root.screenshotsDir
                    root.recordingsDir = data.capture && data.capture.recordingsDir ? data.capture.recordingsDir : root.recordingsDir
                    root.loaded = true
                    root.status = "Loaded"
                } catch (e) {
                    root.loaded = false
                    root.status = "Load failed"
                }
            }
        }
    }

    Process {
        id: saveProc

        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    root.status = "Saved"
                    root.saving = false
                    root.saved()
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    root.status = "Save failed"
                    root.saving = false
                    root.saveFailed(text.trim())
                }
            }
        }
    }
}
