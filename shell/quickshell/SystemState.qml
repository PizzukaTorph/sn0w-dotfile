import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property bool wifiEnabled: false
    property string wifiName: "Disconnected"
    property bool bluetoothPowered: false
    property string vpnName: "Off"
    property string vpnAvailableName: ""
    property string powerProfile: "unknown"
    property int volume: 0
    property bool muted: false
    property int brightness: -1
    property int batteryPercent: -1
    property string batteryStatus: "AC"
    property string battery: batteryPercent >= 0 ? batteryPercent + "%" : "AC"
    property string hostName: "sn0w"
    property string ipAddress: "—"
    property var monitors: []
    property bool busy: false

    function refresh(): void {
        if (!statusProc.running)
            statusProc.running = true
    }

    function runAction(args): void {
        if (actionProc.running)
            return
        actionProc.command = ["sn0w-system"].concat(args)
        busy = true
        actionProc.running = true
    }

    function toggleWifi(): void {
        runAction(["wifi", wifiEnabled ? "off" : "on"])
    }

    function toggleBluetooth(): void {
        runAction(["bluetooth", bluetoothPowered ? "off" : "on"])
    }

    function toggleVpn(): void {
        runAction(["vpn-toggle"])
    }

    function cyclePowerProfile(): void {
        let target = "balanced"
        if (powerProfile === "balanced")
            target = "performance"
        else if (powerProfile === "performance")
            target = "power-saver"
        runAction(["power-profile", target])
    }

    function setPowerProfile(value: string): void {
        runAction(["power-profile", value])
    }

    function setVolume(percent: int): void {
        const safe = Math.max(0, Math.min(100, percent))
        volume = safe
        runAction(["volume", String(safe)])
    }

    function toggleMute(): void {
        runAction(["mute-toggle"])
    }

    function setBrightness(percent: int): void {
        if (brightness < 0)
            return
        const safe = Math.max(1, Math.min(100, percent))
        brightness = safe
        runAction(["brightness", String(safe)])
    }

    function setDisplayScale(scale: real): void {
        runAction(["display-scale", Number(scale).toFixed(2)])
    }

    Process {
        id: statusProc
        command: ["sn0w-system", "status"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text)
                    root.wifiEnabled = data.wifi === true
                    root.wifiName = data.wifiName || "Disconnected"
                    root.bluetoothPowered = data.bluetooth === true
                    root.vpnName = data.vpn || "Off"
                    root.vpnAvailableName = data.vpnAvailable || ""
                    root.powerProfile = data.powerProfile || "unknown"
                    root.volume = data.volume !== undefined ? data.volume : 0
                    root.muted = data.muted === true
                    root.brightness = data.brightness !== undefined ? data.brightness : -1
                    root.batteryPercent = data.battery !== undefined ? data.battery : -1
                    root.batteryStatus = data.batteryStatus || "AC"
                    root.hostName = data.hostName || "sn0w"
                    root.ipAddress = data.ipAddress || "—"
                    root.monitors = data.monitors || []
                } catch (e) {
                }
            }
        }
    }

    Process {
        id: actionProc
        onRunningChanged: {
            if (!running) {
                root.busy = false
                refreshDelay.restart()
            }
        }
    }

    Timer {
        id: refreshDelay
        interval: 300
        repeat: false
        onTriggered: root.refresh()
    }

    Timer {
        interval: 4000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
