import Quickshell
import QtQuick
import QtQuick.Layouts

FloatingWindow {
    id: power

    title: "sn0w Power"
    implicitWidth: 360
    implicitHeight: 250

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

            Text {
                text: "Power"
                color: "#f4f7fb"
                font.pixelSize: 19
                font.bold: true
            }

            Text {
                text: "Session actions"
                color: "#697586"
                font.pixelSize: 11
            }

            Repeater {
                model: [
                    { title: "Lock", hint: "Secure current session" },
                    { title: "Suspend", hint: "Sleep this machine" },
                    { title: "Log out", hint: "Exit Hyprland" },
                    { title: "Power off", hint: "Shut down Fedora" }
                ]

                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    radius: 9
                    color: powerMouse.containsMouse ? "#1b222c" : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10

                        Text {
                            text: modelData.title
                            color: "#f4f7fb"
                            font.pixelSize: 13
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: modelData.hint
                            color: "#697586"
                            font.pixelSize: 10
                        }
                    }

                    MouseArea {
                        id: powerMouse
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }
            }
        }
    }
}
