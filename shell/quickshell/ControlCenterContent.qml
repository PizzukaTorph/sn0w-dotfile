import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: panel
    required property var systemState

    implicitWidth: 410
    implicitHeight: 520
    radius: 18
    color: "#11151b"
    border.width: 0

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 1

                Text {
                    text: "Control Center"
                    color: "#f4f7fb"
                    font.pixelSize: 19
                    font.bold: true
                }

                Text {
                    text: panel.systemState.hostName + " · " + panel.systemState.ipAddress
                    color: "#697586"
                    font.pixelSize: 10
                }
            }

            Item {
                Layout.fillWidth: true
            }

            ColumnLayout {
                spacing: 1

                Text {
                    Layout.alignment: Qt.AlignRight
                    text: panel.systemState.battery
                    color: "#dce3ec"
                    font.pixelSize: 12
                    font.bold: true
                }

                Text {
                    Layout.alignment: Qt.AlignRight
                    text: panel.systemState.batteryStatus
                    color: "#697586"
                    font.pixelSize: 9
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 10
            rowSpacing: 10

            Repeater {
                model: [
                    {
                        label: "Wi-Fi",
                        value: panel.systemState.wifiEnabled ? panel.systemState.wifiName : "Off",
                        active: panel.systemState.wifiEnabled,
                        action: "wifi"
                    },
                    {
                        label: "Bluetooth",
                        value: panel.systemState.bluetoothPowered ? "On" : "Off",
                        active: panel.systemState.bluetoothPowered,
                        action: "bt"
                    },
                    {
                        label: "VPN",
                        value: panel.systemState.vpnName !== "Off"
                               ? panel.systemState.vpnName
                               : (panel.systemState.vpnAvailableName.length > 0 ? "Off · " + panel.systemState.vpnAvailableName : "Not configured"),
                        active: panel.systemState.vpnName !== "Off",
                        action: "vpn"
                    },
                    {
                        label: "Power",
                        value: panel.systemState.powerProfile,
                        active: panel.systemState.powerProfile === "performance",
                        action: "power"
                    }
                ]

                delegate: Rectangle {
                    required property var modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: 76
                    radius: 12
                    color: tileMouse.containsMouse ? "#202936" : (modelData.active ? "#1b252b" : "#171c23")
                    border.width: 1
                    border.color: modelData.active ? "#31414c" : "#242c36"
                    opacity: panel.systemState.busy ? 0.8 : 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 3

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: modelData.label
                                color: "#f4f7fb"
                                font.pixelSize: 13
                                font.bold: true
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                width: 6
                                height: 6
                                radius: 3
                                color: modelData.active ? "#8fb69d" : "#596474"
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.value
                            color: "#7d8998"
                            font.pixelSize: 10
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: tileMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: !panel.systemState.busy
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (modelData.action === "wifi")
                                panel.systemState.toggleWifi()
                            else if (modelData.action === "bt")
                                panel.systemState.toggleBluetooth()
                            else if (modelData.action === "vpn")
                                panel.systemState.toggleVpn()
                            else if (modelData.action === "power")
                                panel.systemState.cyclePowerProfile()
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 92
            radius: 12
            color: "#171c23"
            border.width: 1
            border.color: "#242c36"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Volume"
                        color: "#f4f7fb"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Text {
                        text: panel.systemState.muted ? "muted" : panel.systemState.volume + "%"
                        color: panel.systemState.muted ? "#d8b4ba" : "#697586"
                        font.pixelSize: 10
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Button {
                        text: panel.systemState.muted ? "Unmute" : "Mute"
                        enabled: !panel.systemState.busy
                        onClicked: panel.systemState.toggleMute()
                    }
                }

                Slider {
                    Layout.fillWidth: true
                    enabled: !panel.systemState.busy
                    from: 0
                    to: 100
                    value: panel.systemState.volume
                    onMoved: panel.systemState.setVolume(Math.round(value))
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 82
            radius: 12
            color: "#171c23"
            border.width: 1
            border.color: "#242c36"
            opacity: panel.systemState.brightness >= 0 ? 1 : 0.45

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 5

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Brightness"
                        color: "#f4f7fb"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: panel.systemState.brightness >= 0 ? panel.systemState.brightness + "%" : "unavailable"
                        color: "#697586"
                        font.pixelSize: 10
                    }
                }

                Slider {
                    Layout.fillWidth: true
                    enabled: panel.systemState.brightness >= 0 && !panel.systemState.busy
                    from: 1
                    to: 100
                    value: panel.systemState.brightness >= 0 ? panel.systemState.brightness : 1
                    onMoved: panel.systemState.setBrightness(Math.round(value))
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }

        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: panel.systemState.busy ? "Applying…" : "NetworkManager · PipeWire · tuned-ppd"
            color: "#46515f"
            font.pixelSize: 9
        }
    }
}
