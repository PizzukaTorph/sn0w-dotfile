import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    required property var settingsState

    Layout.fillWidth: true
    Layout.preferredHeight: contentColumn.implicitHeight + 28
    radius: 12
    color: "#171c23"
    border.width: 1
    border.color: "#242c36"

    property real pendingScale: settingsState.displayScale

    SystemState {
        id: live
    }

    function activeMonitor() {
        const monitors = live.monitors || []
        if (monitors.length === 0)
            return null
        for (let i = 0; i < monitors.length; ++i) {
            if (monitors[i].focused)
                return monitors[i]
        }
        return monitors[0]
    }

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 14
        spacing: 14

        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 1

                Text {
                    text: "System"
                    color: "#f4f7fb"
                    font.pixelSize: 13
                    font.bold: true
                }

                Text {
                    text: "One backend for display, sound, power and connectivity"
                    color: "#697586"
                    font.pixelSize: 9
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text: live.busy ? "Applying…" : "Live"
                color: live.busy ? "#d9a56f" : "#8fb69d"
                font.pixelSize: 9
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 102
            radius: 10
            color: "#0d1116"
            border.width: 1
            border.color: "#28313c"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 7

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Display"
                        color: "#f4f7fb"
                        font.pixelSize: 11
                        font.bold: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        property var monitor: root.activeMonitor()
                        text: monitor
                              ? monitor.name + " · " + monitor.width + "×" + monitor.height + " @ " + Number(monitor.refreshRate || 0).toFixed(0) + "Hz"
                              : "No active display"
                        color: "#697586"
                        font.pixelSize: 9
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        Layout.preferredWidth: 84
                        text: "Scale"
                        color: "#8f9aaa"
                        font.pixelSize: 10
                    }

                    Slider {
                        Layout.fillWidth: true
                        from: 0.8
                        to: 3.0
                        stepSize: 0.1
                        value: root.pendingScale
                        onMoved: root.pendingScale = Math.round(value * 10) / 10
                    }

                    Text {
                        Layout.preferredWidth: 42
                        horizontalAlignment: Text.AlignRight
                        text: root.pendingScale.toFixed(1) + "×"
                        color: "#cbd3dd"
                        font.pixelSize: 10
                    }

                    Button {
                        text: "Apply"
                        enabled: !live.busy && Math.abs(root.pendingScale - root.settingsState.displayScale) > 0.001
                        onClicked: root.settingsState.setDisplayScale(root.pendingScale)
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 92
            radius: 10
            color: "#0d1116"
            border.width: 1
            border.color: "#28313c"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 7

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Sound"
                        color: "#f4f7fb"
                        font.pixelSize: 11
                        font.bold: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: live.muted ? "muted" : live.volume + "%"
                        color: live.muted ? "#d8b4ba" : "#697586"
                        font.pixelSize: 9
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        Layout.preferredWidth: 84
                        text: "Output"
                        color: "#8f9aaa"
                        font.pixelSize: 10
                    }

                    Slider {
                        Layout.fillWidth: true
                        enabled: !live.busy
                        from: 0
                        to: 100
                        stepSize: 1
                        value: live.volume
                        onMoved: live.setVolume(Math.round(value))
                    }

                    Button {
                        text: live.muted ? "Unmute" : "Mute"
                        enabled: !live.busy
                        onClicked: live.toggleMute()
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 92
            radius: 10
            color: "#0d1116"
            border.width: 1
            border.color: "#28313c"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 7

                Text {
                    text: "Power"
                    color: "#f4f7fb"
                    font.pixelSize: 11
                    font.bold: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        Layout.preferredWidth: 84
                        text: "Profile"
                        color: "#8f9aaa"
                        font.pixelSize: 10
                    }

                    ComboBox {
                        id: powerCombo
                        Layout.fillWidth: true
                        model: ["power-saver", "balanced", "performance"]
                        currentIndex: Math.max(0, model.indexOf(live.powerProfile))
                        enabled: !live.busy
                        onActivated: live.setPowerProfile(currentText)
                    }

                    Text {
                        text: live.battery + " · " + live.batteryStatus
                        color: "#697586"
                        font.pixelSize: 9
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 144
            radius: 10
            color: "#0d1116"
            border.width: 1
            border.color: "#28313c"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 7

                Text {
                    text: "Network & Bluetooth"
                    color: "#f4f7fb"
                    font.pixelSize: 11
                    font.bold: true
                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.preferredWidth: 84
                        text: "Wi-Fi"
                        color: "#8f9aaa"
                        font.pixelSize: 10
                    }

                    Text {
                        Layout.fillWidth: true
                        text: live.wifiEnabled ? live.wifiName : "Off"
                        color: "#cbd3dd"
                        font.pixelSize: 10
                        elide: Text.ElideRight
                    }

                    Switch {
                        checked: live.wifiEnabled
                        enabled: !live.busy
                        onToggled: live.toggleWifi()
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.preferredWidth: 84
                        text: "Bluetooth"
                        color: "#8f9aaa"
                        font.pixelSize: 10
                    }

                    Text {
                        Layout.fillWidth: true
                        text: live.bluetoothPowered ? "On" : "Off"
                        color: "#cbd3dd"
                        font.pixelSize: 10
                    }

                    Switch {
                        checked: live.bluetoothPowered
                        enabled: !live.busy
                        onToggled: live.toggleBluetooth()
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.preferredWidth: 84
                        text: "VPN"
                        color: "#8f9aaa"
                        font.pixelSize: 10
                    }

                    Text {
                        Layout.fillWidth: true
                        text: live.vpnName !== "Off" ? live.vpnName : (live.vpnAvailableName || "Not configured")
                        color: "#cbd3dd"
                        font.pixelSize: 10
                        elide: Text.ElideRight
                    }

                    Button {
                        text: live.vpnName !== "Off" ? "Disconnect" : "Connect"
                        enabled: !live.busy && (live.vpnName !== "Off" || live.vpnAvailableName.length > 0)
                        onClicked: live.toggleVpn()
                    }
                }
            }
        }
    }

    Connections {
        target: root.settingsState

        function onDisplayScaleChanged(): void {
            root.pendingScale = root.settingsState.displayScale
        }
    }
}
