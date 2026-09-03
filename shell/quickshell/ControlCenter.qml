import Quickshell
import QtQuick
import QtQuick.Layouts

FloatingWindow {
    id: panel

    title: "sn0w Control Center"
    implicitWidth: 390
    implicitHeight: 510

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: "#11151b"
        border.width: 1
        border.color: "#2b3440"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

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
                        text: "sn0w system controls"
                        color: "#697586"
                        font.pixelSize: 11
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 9
                    height: 9
                    radius: 5
                    color: "#7d8998"
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 10
                rowSpacing: 10

                Repeater {
                    model: [
                        { title: "Wi-Fi", value: "NetworkManager", glyph: "⌁" },
                        { title: "Bluetooth", value: "Devices", glyph: "ᛒ" },
                        { title: "VPN", value: "WireGuard", glyph: "◈" },
                        { title: "Power", value: "Balanced", glyph: "◐" }
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 78
                        radius: 12
                        color: tileMouse.containsMouse ? "#1b222c" : "#171c23"
                        border.width: 1
                        border.color: "#242c36"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 34
                                Layout.preferredHeight: 34
                                radius: 10
                                color: "#252d38"

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.glyph
                                    color: "#f4f7fb"
                                    font.pixelSize: 16
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    text: modelData.title
                                    color: "#f4f7fb"
                                    font.pixelSize: 13
                                    font.bold: true
                                }

                                Text {
                                    text: modelData.value
                                    color: "#7d8998"
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        MouseArea {
                            id: tileMouse
                            anchors.fill: parent
                            hoverEnabled: true
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

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Volume"
                            color: "#f4f7fb"
                            font.pixelSize: 12
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: "PipeWire"
                            color: "#697586"
                            font.pixelSize: 10
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 6
                        radius: 3
                        color: "#29313c"

                        Rectangle {
                            width: parent.width * 0.62
                            height: parent.height
                            radius: 3
                            color: "#aab4c2"
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

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Brightness"
                            color: "#f4f7fb"
                            font.pixelSize: 12
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: "Display"
                            color: "#697586"
                            font.pixelSize: 10
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 6
                        radius: 3
                        color: "#29313c"

                        Rectangle {
                            width: parent.width * 0.74
                            height: parent.height
                            radius: 3
                            color: "#aab4c2"
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "V1 surface · live backends next"
                color: "#596474"
                font.pixelSize: 10
            }
        }
    }
}
