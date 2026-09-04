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

    property string keyboardLayout: "us"
    property string keyboardVariant: "mac"
    property bool naturalScroll: true
    property bool tapToClick: true
    property bool twoFingerRightClick: true
    property bool tapAndDrag: true
    property int dragLock: 1
    property bool disableWhileTyping: true
    property real pointerSpeed: 0.0
    property real touchpadScrollFactor: 1.0
    property real mouseScrollFactor: 1.0
    property bool gesturesEnabled: true

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
            projects: { roots: projectRoots },
            ssh: { hosts: sshHosts },
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
                keyboardLayout: keyboardLayout,
                keyboardVariant: keyboardVariant,
                naturalScroll: naturalScroll,
                tapToClick: tapToClick,
                twoFingerRightClick: twoFingerRightClick,
                tapAndDrag: tapAndDrag,
                dragLock: dragLock,
                disableWhileTyping: disableWhileTyping,
                pointerSpeed: pointerSpeed,
                touchpadScrollFactor: touchpadScrollFactor,
                mouseScrollFactor: mouseScrollFactor,
                gesturesEnabled: gesturesEnabled
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

    function scheduleInputCommit(): void {
        inputApplyTimer.restart()
        inputSaveTimer.restart()
    }

    function applyInputSettings(): void {
        const natural = naturalScroll ? "true" : "false"
        const tap = tapToClick ? "true" : "false"
        const clickfinger = twoFingerRightClick ? "true" : "false"
        const tapDrag = tapAndDrag ? "true" : "false"
        const dwt = disableWhileTyping ? "true" : "false"
        const layout = keyboardLayout.length > 0 ? keyboardLayout : "us"
        const variant = keyboardVariant || ""
        const gesturesCommand = gesturesEnabled
            ? "rm -f ~/.config/sn0w/gestures-disabled"
            : "mkdir -p ~/.config/sn0w && touch ~/.config/sn0w/gestures-disabled"

        inputProc.command = [
            "sh",
            "-lc",
            "hyprctl keyword input:kb_layout '" + layout + "' >/dev/null; " +
            "hyprctl keyword input:kb_variant '" + variant + "' >/dev/null; " +
            "hyprctl keyword input:natural_scroll " + natural + " >/dev/null; " +
            "hyprctl keyword input:touchpad:natural_scroll " + natural + " >/dev/null; " +
            "hyprctl keyword input:touchpad:tap_to_click " + tap + " >/dev/null; " +
            "hyprctl keyword input:touchpad:clickfinger_behavior " + clickfinger + " >/dev/null; " +
            "hyprctl keyword input:touchpad:tap_and_drag " + tapDrag + " >/dev/null; " +
            "hyprctl keyword input:touchpad:drag_lock " + dragLock + " >/dev/null; " +
            "hyprctl keyword input:touchpad:disable_while_typing " + dwt + " >/dev/null; " +
            "hyprctl keyword input:sensitivity " + pointerSpeed.toFixed(2) + " >/dev/null; " +
            "hyprctl keyword input:touchpad:scroll_factor " + touchpadScrollFactor.toFixed(2) + " >/dev/null; " +
            "hyprctl keyword input:scroll_factor " + mouseScrollFactor.toFixed(2) + " >/dev/null; " +
            gesturesCommand
        ]

        if (inputProc.running)
            inputProc.running = false
        inputProc.running = true
    }

    function setKeyboardMap(layout: string, variant: string): void {
        const cleanLayout = layout.trim().toLowerCase()
        const cleanVariant = variant.trim().toLowerCase()
        if (cleanLayout.length === 0)
            return
        keyboardLayout = cleanLayout
        keyboardVariant = cleanVariant
        scheduleInputCommit()
    }

    function setNaturalScroll(value: bool): void { naturalScroll = value; scheduleInputCommit() }
    function setTapToClick(value: bool): void { tapToClick = value; scheduleInputCommit() }
    function setTwoFingerRightClick(value: bool): void { twoFingerRightClick = value; scheduleInputCommit() }
    function setTapAndDrag(value: bool): void { tapAndDrag = value; scheduleInputCommit() }
    function setDragLock(value: int): void { dragLock = Math.max(0, Math.min(2, value)); scheduleInputCommit() }
    function setDisableWhileTyping(value: bool): void { disableWhileTyping = value; scheduleInputCommit() }
    function setPointerSpeed(value: real): void { pointerSpeed = Math.max(-1.0, Math.min(1.0, value)); scheduleInputCommit() }
    function setTouchpadScrollFactor(value: real): void { touchpadScrollFactor = Math.max(0.25, Math.min(2.0, value)); scheduleInputCommit() }
    function setMouseScrollFactor(value: real): void { mouseScrollFactor = Math.max(0.25, Math.min(2.0, value)); scheduleInputCommit() }
    function setGesturesEnabled(value: bool): void { gesturesEnabled = value; scheduleInputCommit() }

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
        const payload = JSON.stringify({ endpoint: endpoint, password: password || "" })
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

    Timer { id: inputApplyTimer; interval: 80; repeat: false; onTriggered: root.applyInputSettings() }
    Timer { id: inputSaveTimer; interval: 300; repeat: false; onTriggered: root.save() }

    Process {
        id: loadProc
        command: [
            "python3",
            "-c",
            "import json,os; p=os.path.expanduser('~/.config/sn0w/settings.json'); d={'projects':{'roots':['~/Code','~/Projects','~/Dev','/mnt']},'ssh':{'hosts':[]},'apps':{'terminal':'foot','fileManager':'nautilus','editor':'code'},'capture':{'screenshotsDir':'~/Pictures/Screenshots','recordingsDir':'~/Videos/Captures'},'input':{'keyboardLayout':'us','keyboardVariant':'mac','naturalScroll':True,'tapToClick':True,'twoFingerRightClick':True,'tapAndDrag':True,'dragLock':1,'disableWhileTyping':True,'pointerSpeed':0.0,'touchpadScrollFactor':1.0,'mouseScrollFactor':1.0,'gesturesEnabled':True}}; os.makedirs(os.path.dirname(p),exist_ok=True);\nif os.path.exists(p):\n  try:\n    u=json.load(open(p));\n    for k,v in u.items():\n      if isinstance(v,dict) and isinstance(d.get(k),dict): d[k].update(v)\n      else: d[k]=v\n  except Exception: pass\nelse:\n  json.dump(d,open(p,'w'),indent=2)\nprint(json.dumps(d))"
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
                    const input = data.input || {}
                    root.keyboardLayout = input.keyboardLayout || "us"
                    root.keyboardVariant = input.keyboardVariant !== undefined ? input.keyboardVariant : ""
                    root.naturalScroll = input.naturalScroll !== undefined ? input.naturalScroll : true
                    root.tapToClick = input.tapToClick !== undefined ? input.tapToClick : true
                    root.twoFingerRightClick = input.twoFingerRightClick !== undefined ? input.twoFingerRightClick : true
                    root.tapAndDrag = input.tapAndDrag !== undefined ? input.tapAndDrag : true
                    root.dragLock = input.dragLock !== undefined ? input.dragLock : 1
                    root.disableWhileTyping = input.disableWhileTyping !== undefined ? input.disableWhileTyping : true
                    root.pointerSpeed = input.pointerSpeed !== undefined ? input.pointerSpeed : 0.0
                    root.touchpadScrollFactor = input.touchpadScrollFactor !== undefined ? input.touchpadScrollFactor : 1.0
                    root.mouseScrollFactor = input.mouseScrollFactor !== undefined ? input.mouseScrollFactor : 1.0
                    root.gesturesEnabled = input.gesturesEnabled !== undefined ? input.gesturesEnabled : true
                    root.loaded = true
                    root.status = "Loaded"
                    root.applyInputSettings()
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

    Process { id: inputProc }

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
