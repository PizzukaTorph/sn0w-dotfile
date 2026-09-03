import Quickshell
import QtQuick
import QtQuick.Layouts

Scope {
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

            implicitHeight: 34
            color: "#0b0d10"

            Rectangle {
                anchors.fill: parent
                color: "#0b0d10"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10

                    Text {
                        text: "sn0w"
                        color: "#f4f7fb"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    Text {
                        text: "General"
                        color: "#8b95a5"
                        font.pixelSize: 12
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: Qt.formatDateTime(clock.date, "ddd d MMM  HH:mm")
                        color: "#f4f7fb"
                        font.pixelSize: 12
                    }
                }
            }
        }
    }
}
