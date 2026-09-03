import Quickshell
import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    property string mode: "General"
    property var systemState
    signal launcherRequested()
    signal controlCenterRequested()
    signal powerRequested()

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 36
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: "#e60b0d10"
                border.width: 1
                border.color: "#202630"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 10
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: brandRow.implicitWidth + 16
                        Layout.preferredHeight: 26
                        radius: 8
                        color: brandMouse.containsMouse ? "#1b222c" : "transparent"

                        RowLayout {
                            id: brandRow
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: "sn0w"
                                color: "#f4f7fb"
                                font.pixelSize: 14
                                font.bold: true
                            }

                            Rectangle {
                                width: 4
                                height: 4
                                radius: 2
                                color: "#7d8998"
                            }

                            Text {
                                text: root.mode
                                color: "#9aa5b4"
                                font.pixelSize: 12
                            }
                        }

                        MouseArea {
                            id: brandMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.launcherRequested()
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        visible: root.systemState !== undefined && root.systemState !== null
                        text: root.systemState && root.systemState.wifiEnabled
                              ? (root.systemState.wifiName === "Disconnected" ? "Wi-Fi" : root.systemState.wifiName)
                              : "Wi-Fi off"
                        color: "#8f9aaa"
                        font.pixelSize: 10
                    }

                    Text {
                        visible: root.systemState !== undefined && root.systemState !== null
                        text: root.systemState ? root.systemState.battery : ""
                        color: "#8f9aaa"
                        font.pixelSize: 10
                    }

                    Rectangle {
                        Layout.preferredWidth: clockText.implicitWidth + 16
                        Layout.preferredHeight: 26
                        radius: 8
                        color: controlMouse.containsMouse ? "#1b222c" : "transparent"

                        Text {
                            id: clockText
                            anchors.centerIn: parent
                            text: Qt.formatDateTime(clock.date, "ddd d MMM  HH:mm")
                            color: "#e7ecf3"
                            font.pixelSize: 12
                        }

                        MouseArea {
                            id: controlMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.controlCenterRequested()
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 26
                        radius: 8
                        color: powerMouse.containsMouse ? "#322027" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "⏻"
                            color: "#b9c2ce"
                            font.pixelSize: 14
                        }

                        MouseArea {
                            id: powerMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.powerRequested()
                        }
                    }
                }
            }
        }
    }
}
