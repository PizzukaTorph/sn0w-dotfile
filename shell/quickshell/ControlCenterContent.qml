import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: panel
    required property var systemState

    implicitWidth: 410
    implicitHeight: 500
    radius: 18
    color: "#11151b"
    border.width: 0

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                spacing: 1
                Text { text: "Control Center"; color: "#f4f7fb"; font.pixelSize: 19; font.bold: true }
                Text { text: panel.systemState.hostName + " · " + panel.systemState.ipAddress; color: "#697586"; font.pixelSize: 11 }
            }
            Item { Layout.fillWidth: true }
            Text { text: panel.systemState.battery; color: "#aab4c2"; font.pixelSize: 12 }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 10
            rowSpacing: 10

            Repeater {
                model: [
                    { label: "Wi-Fi", value: panel.systemState.wifiEnabled ? panel.systemState.wifiName : "Off", action: "wifi" },
                    { label: "Bluetooth", value: panel.systemState.bluetoothPowered ? "On" : "Off", action: "bt" },
                    { label: "VPN", value: panel.systemState.vpnName, action: "vpn" },
                    { label: "Power", value: panel.systemState.powerProfile, action: "power" }
                ]
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 76
                    radius: 12
                    color: tileMouse.containsMouse ? "#202936" : "#171c23"
                    border.width: 1
                    border.color: "#242c36"
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 3
                        Text { text: modelData.label; color: "#f4f7fb"; font.pixelSize: 13; font.bold: true }
                        Text { Layout.fillWidth: true; text: modelData.value; color: "#7d8998"; font.pixelSize: 10; elide: Text.ElideRight }
                    }
                    MouseArea {
                        id: tileMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.action === "wifi") panel.systemState.toggleWifi()
                            else if (modelData.action === "bt") panel.systemState.toggleBluetooth()
                            else if (modelData.action === "vpn") panel.systemState.toggleVpn()
                            else if (modelData.action === "power") panel.systemState.cyclePowerProfile()
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
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: panel.systemState.muted ? "Volume · muted" : "Volume"; color: "#f4f7fb"; font.pixelSize: 12 }
                    Item { Layout.fillWidth: true }
                    Text { text: panel.systemState.volume + "%"; color: "#697586"; font.pixelSize: 10 }
                }
                Slider { Layout.fillWidth: true; from: 0; to: 100; value: panel.systemState.volume; onMoved: panel.systemState.setVolume(Math.round(value)) }
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
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Brightness"; color: "#f4f7fb"; font.pixelSize: 12 }
                    Item { Layout.fillWidth: true }
                    Text { text: panel.systemState.brightness >= 0 ? panel.systemState.brightness + "%" : "unavailable"; color: "#697586"; font.pixelSize: 10 }
                }
                Slider { Layout.fillWidth: true; enabled: panel.systemState.brightness >= 0; from: 1; to: 100; value: panel.systemState.brightness >= 0 ? panel.systemState.brightness : 1; onMoved: panel.systemState.setBrightness(Math.round(value)) }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
