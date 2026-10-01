import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

FloatingWindow {
    id: panel

    property var systemState

    title: "sn0w Control Center"
    implicitWidth: 410
    implicitHeight: 560

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: "#11151b"
        border.width: 1
        border.color: "#2b3440"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 13

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
                        text: panel.systemState
                              ? panel.systemState.hostName + " · " + panel.systemState.ipAddress
                              : "sn0w"
                        color: "#697586"
                        font.pixelSize: 11
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: panel.systemState ? panel.systemState.battery : ""
                    color: "#aab4c2"
                    font.pixelSize: 12
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 10
                rowSpacing: 10

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 78
                    radius: 12
                    color: wifiMouse.containsMouse ? "#202936" : "#171c23"
                    border.width: 1
                    border.color: panel.systemState && panel.systemState.wifiEnabled ? "#59697c" : "#242c36"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10
                        Text { text: "⌁"; color: "#f4f7fb"; font.pixelSize: 19 }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text { text: "Wi-Fi"; color: "#f4f7fb"; font.pixelSize: 13; font.bold: true }
                            Text {
                                Layout.fillWidth: true
                                text: panel.systemState
                                      ? (panel.systemState.wifiEnabled ? panel.systemState.wifiName : "Off")
                                      : "…"
                                color: "#7d8998"
                                font.pixelSize: 10
                                elide: Text.ElideRight
                            }
                        }
                    }
                    MouseArea {
                        id: wifiMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (panel.systemState) panel.systemState.toggleWifi()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 78
                    radius: 12
                    color: btMouse.containsMouse ? "#202936" : "#171c23"
                    border.width: 1
                    border.color: panel.systemState && panel.systemState.bluetoothPowered ? "#59697c" : "#242c36"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10
                        Text { text: "ᛒ"; color: "#f4f7fb"; font.pixelSize: 17 }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text { text: "Bluetooth"; color: "#f4f7fb"; font.pixelSize: 13; font.bold: true }
                            Text {
                                text: panel.systemState && panel.systemState.bluetoothPowered ? "On" : "Off"
                                color: "#7d8998"
                                font.pixelSize: 10
                            }
                        }
                    }
                    MouseArea {
                        id: btMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (panel.systemState) panel.systemState.toggleBluetooth()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 78
                    radius: 12
                    color: vpnMouse.containsMouse ? "#202936" : "#171c23"
                    border.width: 1
                    border.color: panel.systemState && panel.systemState.vpnName !== "Off" ? "#59697c" : "#242c36"
                    opacity: panel.systemState && (panel.systemState.vpnName !== "Off" || panel.systemState.vpnAvailableName.length > 0) ? 1.0 : 0.5

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10
                        Text { text: "◈"; color: "#f4f7fb"; font.pixelSize: 17 }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text { text: "VPN"; color: "#f4f7fb"; font.pixelSize: 13; font.bold: true }
                            Text {
                                Layout.fillWidth: true
                                text: panel.systemState
                                      ? (panel.systemState.vpnName !== "Off"
                                         ? panel.systemState.vpnName
                                         : (panel.systemState.vpnAvailableName.length > 0
                                            ? panel.systemState.vpnAvailableName + " · Off"
                                            : "Unavailable"))
                                      : "…"
                                color: "#7d8998"
                                font.pixelSize: 10
                                elide: Text.ElideRight
                            }
                        }
                    }
                    MouseArea {
                        id: vpnMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: panel.systemState && (panel.systemState.vpnName !== "Off" || panel.systemState.vpnAvailableName.length > 0)
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: if (panel.systemState) panel.systemState.toggleVpn()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 78
                    radius: 12
                    color: powerMouse.containsMouse ? "#202936" : "#171c23"
                    border.width: 1
                    border.color: "#242c36"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10
                        Text { text: "◐"; color: "#f4f7fb"; font.pixelSize: 17 }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text { text: "Power"; color: "#f4f7fb"; font.pixelSize: 13; font.bold: true }
                            Text {
                                Layout.fillWidth: true
                                text: panel.systemState ? panel.systemState.powerProfile : "…"
                                color: "#7d8998"
                                font.pixelSize: 10
                                elide: Text.ElideRight
                            }
                        }
                    }
                    MouseArea {
                        id: powerMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (panel.systemState) panel.systemState.cyclePowerProfile()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 94
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
                            text: panel.systemState && panel.systemState.muted ? "Volume · muted" : "Volume"
                            color: "#f4f7fb"
                            font.pixelSize: 12
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: panel.systemState ? panel.systemState.volume + "%" : "—"
                            color: "#697586"
                            font.pixelSize: 10
                        }
                    }

                    Slider {
                        id: volumeSlider
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        value: panel.systemState ? panel.systemState.volume : 0
                        onMoved: if (panel.systemState) panel.systemState.setVolume(Math.round(value))
                    }

                    Text {
                        text: "click label to mute"
                        color: "#596474"
                        font.pixelSize: 9
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (panel.systemState) panel.systemState.toggleMute()
                        }
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
                opacity: panel.systemState && panel.systemState.brightness >= 0 ? 1.0 : 0.45

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Brightness"; color: "#f4f7fb"; font.pixelSize: 12 }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: panel.systemState && panel.systemState.brightness >= 0
                                  ? panel.systemState.brightness + "%"
                                  : "unavailable"
                            color: "#697586"
                            font.pixelSize: 10
                        }
                    }

                    Slider {
                        Layout.fillWidth: true
                        enabled: panel.systemState && panel.systemState.brightness >= 0
                        from: 1
                        to: 100
                        value: panel.systemState && panel.systemState.brightness >= 0
                               ? panel.systemState.brightness
                               : 1
                        onMoved: if (panel.systemState) panel.systemState.setBrightness(Math.round(value))
                    }
                }
            }

            Item { Layout.fillHeight: true }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "NetworkManager · BlueZ · PipeWire · tuned-ppd · brightnessctl"
                color: "#596474"
                font.pixelSize: 9
            }
        }
    }
}
