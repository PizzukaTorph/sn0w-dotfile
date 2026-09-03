import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property bool wifiEnabled: false
    property string wifiName: "Disconnected"
    property bool bluetoothPowered: false
    property string vpnName: "Off"
    property string powerProfile: "unknown"
    property int volume: 0
    property bool muted: false
    property int brightness: -1
    property string battery: "AC"
    property string hostName: "sn0w"
    property string ipAddress: "—"

    function refresh(): void {
        if (!wifiProc.running) wifiProc.running = true;
        if (!ssidProc.running) ssidProc.running = true;
        if (!btProc.running) btProc.running = true;
        if (!profileProc.running) profileProc.running = true;
        if (!volumeProc.running) volumeProc.running = true;
        if (!brightnessProc.running) brightnessProc.running = true;
        if (!hostProc.running) hostProc.running = true;
        if (!ipProc.running) ipProc.running = true;
    }

    function toggleWifi(): void {
        actionProc.command = ["nmcli", "radio", "wifi", wifiEnabled ? "off" : "on"];
        actionProc.running = true;
    }

    function toggleBluetooth(): void {
        actionProc.command = ["bluetoothctl", "power", bluetoothPowered ? "off" : "on"];
        actionProc.running = true;
    }

    function cyclePowerProfile(): void {
        let target = "balanced";
        if (powerProfile === "balanced") target = "performance";
        else if (powerProfile === "performance") target = "power-saver";
        actionProc.command = [
            "busctl", "set-property",
            "org.freedesktop.UPower.PowerProfiles",
            "/org/freedesktop/UPower/PowerProfiles",
            "org.freedesktop.UPower.PowerProfiles",
            "ActiveProfile", "s", target
        ];
        actionProc.running = true;
    }

    function setVolume(percent: int): void {
        const safe = Math.max(0, Math.min(100, percent));
        actionProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", safe + "%"];
        actionProc.running = true;
    }

    function toggleMute(): void {
        actionProc.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"];
        actionProc.running = true;
    }

    function setBrightness(percent: int): void {
        if (brightness < 0) return;
        const safe = Math.max(1, Math.min(100, percent));
        actionProc.command = ["brightnessctl", "set", safe + "%"];
        actionProc.running = true;
    }

    Process {
        id: wifiProc
        command: ["nmcli", "radio", "wifi"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.wifiEnabled = text.trim() === "enabled"
        }
    }

    Process {
        id: ssidProc
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID", "dev", "wifi"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const rows = text.trim().split("\n");
                root.wifiName = "Disconnected";
                for (const row of rows) {
                    if (row.indexOf("yes:") === 0) {
                        root.wifiName = row.slice(4);
                        break;
                    }
                }
            }
        }
    }

    Process {
        id: btProc
        command: ["bluetoothctl", "show"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.bluetoothPowered = text.indexOf("Powered: yes") >= 0
        }
    }

    Process {
        id: profileProc
        command: [
            "busctl", "get-property",
            "org.freedesktop.UPower.PowerProfiles",
            "/org/freedesktop/UPower/PowerProfiles",
            "org.freedesktop.UPower.PowerProfiles",
            "ActiveProfile"
        ]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const match = text.match(/\"([^\"]+)\"/);
                root.powerProfile = match ? match[1] : "unknown";
            }
        }
    }

    Process {
        id: volumeProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const match = text.match(/Volume:\s+([0-9.]+)/);
                root.volume = match ? Math.round(Number(match[1]) * 100) : 0;
                root.muted = text.indexOf("MUTED") >= 0;
            }
        }
    }

    Process {
        id: brightnessProc
        command: ["brightnessctl", "-m"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split(",");
                root.brightness = fields.length >= 4 ? Number(fields[3].replace("%", "")) : -1;
            }
        }
    }

    Process {
        id: hostProc
        command: ["hostname"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) root.hostName = text.trim();
            }
        }
    }

    Process {
        id: ipProc
        command: ["hostname", "-I"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const addresses = text.trim().split(/\s+/);
                root.ipAddress = addresses.length > 0 && addresses[0].length > 0 ? addresses[0] : "—";
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
        interval: 500
        onTriggered: root.refresh()
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
