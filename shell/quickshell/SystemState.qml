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
        if (!statusProc.running)
            statusProc.running = true;
    }

    function run(command: string): void {
        actionProc.command = ["sh", "-lc", command];
        actionProc.running = true;
    }

    function toggleWifi(): void {
        run("nmcli radio wifi " + (wifiEnabled ? "off" : "on"));
    }

    function toggleBluetooth(): void {
        run("bluetoothctl power " + (bluetoothPowered ? "off" : "on"));
    }

    function cyclePowerProfile(): void {
        let target = "balanced";
        if (powerProfile === "balanced")
            target = "performance";
        else if (powerProfile === "performance")
            target = "power-saver";
        run("powerprofilesctl set " + target);
    }

    function setVolume(percent: int): void {
        const safe = Math.max(0, Math.min(100, percent));
        run("wpctl set-volume @DEFAULT_AUDIO_SINK@ " + safe + "%");
    }

    function toggleMute(): void {
        run("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle");
    }

    function setBrightness(percent: int): void {
        if (brightness < 0)
            return;
        const safe = Math.max(1, Math.min(100, percent));
        run("brightnessctl set " + safe + "%");
    }

    Process {
        id: statusProc
        command: ["sh", "-lc", """
            wifi=$(nmcli radio wifi 2>/dev/null || echo disabled)
            ssid=$(nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | awk -F: '$1 == \"yes\" {sub(/^yes:/, \"\"); print; exit}')
            [ -n \"$ssid\" ] || ssid=Disconnected
            bt=$(bluetoothctl show 2>/dev/null | awk '/Powered:/ {print $2; exit}')
            [ -n \"$bt\" ] || bt=no
            vpn=$(nmcli -t -f TYPE,NAME connection show --active 2>/dev/null | awk -F: '$1 == \"wireguard\" || $1 == \"vpn\" {print $2; exit}')
            [ -n \"$vpn\" ] || vpn=Off
            profile=$(powerprofilesctl get 2>/dev/null || echo unknown)
            vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)
            voln=$(printf '%s' \"$vol\" | awk '{printf \"%d\", $2 * 100}')
            [ -n \"$voln\" ] || voln=0
            case \"$vol\" in *MUTED*) mute=yes ;; *) mute=no ;; esac
            bright=$(brightnessctl -m 2>/dev/null | awk -F, 'NR == 1 {gsub(/%/, \"\", $4); print $4}')
            [ -n \"$bright\" ] || bright=-1
            bat=$(for b in /sys/class/power_supply/BAT*; do [ -r \"$b/capacity\" ] && { cat \"$b/capacity\"; break; }; done)
            [ -n \"$bat\" ] && bat=\"${bat}%\" || bat=AC
            host=$(hostname 2>/dev/null || echo sn0w)
            ip=$(hostname -I 2>/dev/null | awk '{print $1}')
            [ -n \"$ip\" ] || ip='—'
            printf 'wifi=%s\nssid=%s\nbt=%s\nvpn=%s\nprofile=%s\nvolume=%s\nmute=%s\nbrightness=%s\nbattery=%s\nhost=%s\nip=%s\n' \
                \"$wifi\" \"$ssid\" \"$bt\" \"$vpn\" \"$profile\" \"$voln\" \"$mute\" \"$bright\" \"$bat\" \"$host\" \"$ip\"
        """]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                for (const line of lines) {
                    const split = line.indexOf("=");
                    if (split < 0)
                        continue;
                    const key = line.slice(0, split);
                    const value = line.slice(split + 1);
                    if (key === "wifi") root.wifiEnabled = value === "enabled";
                    else if (key === "ssid") root.wifiName = value;
                    else if (key === "bt") root.bluetoothPowered = value === "yes";
                    else if (key === "vpn") root.vpnName = value;
                    else if (key === "profile") root.powerProfile = value;
                    else if (key === "volume") root.volume = Number(value);
                    else if (key === "mute") root.muted = value === "yes";
                    else if (key === "brightness") root.brightness = Number(value);
                    else if (key === "battery") root.battery = value;
                    else if (key === "host") root.hostName = value;
                    else if (key === "ip") root.ipAddress = value;
                }
            }
        }
    }

    Process {
        id: actionProc
        onRunningChanged: {
            if (!running)
                refreshTimer.restart();
        }
    }

    Timer {
        id: refreshTimer
        interval: 700
        onTriggered: root.refresh()
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
