import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

FloatingWindow {
    id: launcher

    title: "sn0w launcher"
    implicitWidth: 640
    implicitHeight: 360
    color: "#11151b"

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: "#11151b"
        border.width: 1
        border.color: "#2b3440"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 22
            spacing: 14

            Text {
                text: "sn0w"
                color: "#f4f7fb"
                font.pixelSize: 22
                font.bold: true
            }

            TextField {
                id: query
                Layout.fillWidth: true
                placeholderText: "Apps, projects, actions…"
                font.pixelSize: 16
                focus: launcher.visible
                onAccepted: {
                    // Desktop-entry execution lands in Launcher V1.
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: "#0b0d10"

                Text {
                    anchors.centerIn: parent
                    text: query.text.length === 0
                        ? "Launcher V0 · fuzzy app index next"
                        : "Search: " + query.text
                    color: "#8b95a5"
                    font.pixelSize: 14
                }
            }

            Text {
                text: "⌘Space toggle · Esc support next"
                color: "#697586"
                font.pixelSize: 11
            }
        }
    }
}
