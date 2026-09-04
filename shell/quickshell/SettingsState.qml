import Quickshell.Io
import QtQuick

Item {
    id: root

    property var projectRoots: ["~/Code", "~/Projects", "~/Dev", "/mnt"]
    property var sshHosts: []
    property string terminal: "foot"
    property string fileManager: "nautilus"
    property string editor: "code"
    property string screenshotsDir: "~/Pictures/Screenshots"
    property string recordingsDir: "~/Videos/Captures"
    property bool naturalScroll: true
    property bool loaded: false
    property bool saving: false
    property bool sshBusy: false
    property string status: ""
    property string sshStatus: ""

    signal saved()
    signal saveFailed(string message)
    signal sshChanged()
    signal sshFailed(string message)

    function normalizeSshHosts(values) {
        const result = []
        if (!values)
            return result

        for (let i = 0; i < values.length; ++i) {
            const value = values[i]
            if (typeof value === "string") {
                result.push({
                    name: value,
                    host: value,
                    port: 22,
                    user: "",
                    auth: "key",
                    legacy: true
                })
            } else if (value && value.name) {
                result.push(value)
            }
        }
        return result
    }

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
            },
            input: {
                naturalScroll: naturalScroll
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

    function applyNaturalScroll(): void {
        const value = naturalScroll ? "true" : "false"
        naturalScrollProc.command = [
            "sh",
            "-lc",
            "hyprctl keyword input:natural_scroll " + value + " >/dev/null && hyprctl keyword input:touchpad:natural_scroll " + value + " >/dev/null"
        ]
        if (naturalScrollProc.running)
            naturalScrollProc.running = false
        naturalScrollProc.running = true
    }

    function setNaturalScroll(enabled: bool): void {
        naturalScroll = enabled
        applyNaturalScroll()
        save()
    }

    function addProjectRoot(value: string): void {
        const clean = value.trim()
        if (clean.length === 0 || projectRoots.indexOf(clean) >= 0)
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

    function saveSshEndpoint(endpoint, password: string): void {
        if (!endpoint || !endpoint.name || !endpoint.host || !endpoint.user)
            return

        const payload = JSON.stringify({
            endpoint: endpoint,
            password: password || ""
        })

        sshBusy = true
        sshStatus = "Saving SSH…"
        sshProc.command = ["sn0w-ssh-configure", "save", payload]
        if (sshProc.running)
            sshProc.running = false
        sshProc.running = true
    }

    function removeSshHost(index: int): void {
        if (index < 0 || index >= sshHosts.length)
            return
        const endpoint = sshHosts[index]
        const alias = endpoint && endpoint.name ? endpoint.name : ""
        if (alias.length === 0)
            return

        sshBusy = true
        sshStatus = "Removing SSH…"
        sshProc.command = ["sn0w-ssh-configure", "remove", alias]
        if (sshProc.running)
            sshProc.running = false
        sshProc.running = true
    }

    Process {
        id: loadProc
        command: [
            "python3",
            "-c",
            "import json,os; p=os.path.expanduser('~/.config/sn0w/settings.json'); d={'projects':{'roots':['~/Code','~/Projects','~/Dev','/mnt']},'ssh':{'hosts':[]},'apps':{'terminal':'foot','fileManager':'nautilus','editor':'code'},'capture':{'screenshotsDir':'~/Pictures/Screenshots','recordingsDir':'~/Videos/Captures'},'input':{'naturalScroll':True}}; os.makedirs(os.path.dirname(p),exist_ok=True);\nif os.path.exists(p):\n  try:\n    u=json.load(open(p));\n    for k,v in u.items():\n      if isinstance(v,dict) and isinstance(d.get(k),dict): d[k].update(v)\n      else: d[k]=v\n  except Exception: pass\nelse:\n  json.dump(d,open(p,'w'),indent=2)\nprint(json.dumps(d))"
        ]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text)
                    root.projectRoots = data.projects && data.projects.roots ? data.projects.roots : root.projectRoots
                    root.sshHosts = root.normalizeSshHosts(data.ssh && data.ssh.hosts ? data.ssh.hosts : [])
                    root.terminal = data.apps && data.apps.terminal ? data.apps.terminal : root.terminal
                    root.fileManager = data.apps && data.apps.fileManager ? data.apps.fileManager : root.fileManager
                    root.editor = data.apps && data.apps.editor ? data.apps.editor : root.editor
                    root.screenshotsDir = data.capture && data.capture.screenshotsDir ? data.capture.screenshotsDir : root.screenshotsDir
                    root.recordingsDir = data.capture && data.capture.recordingsDir ? data.capture.recordingsDir : root.recordingsDir
                    root.naturalScroll = data.input && data.input.naturalScroll !== undefined ? data.input.naturalScroll : true
                    root.loaded = true
                    root.status = "Loaded"
                    root.applyNaturalScroll()
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

    Process {
        id: naturalScrollProc
    }

    Process {
        id: sshProc

        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    root.sshBusy = false
                    root.sshStatus = "SSH saved"
                    root.load()
                    root.sshChanged()
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    root.sshBusy = false
                    root.sshStatus = "SSH failed"
                    root.sshFailed(text.trim())
                }
            }
        }
    }
}
