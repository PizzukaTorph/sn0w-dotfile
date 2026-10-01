import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

FloatingWindow {
    id: panel

    implicitWidth: 520
    implicitHeight: 230
    title: "sn0w Capture"
    color: "transparent"

    function run(command: string): void {
        captureProc.command = ["sh", "-lc", command]
        captureProc.running = true
        visible = false
    }

    Process { id: captureProc }

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
                Text { text: "Capture"; color: "#f4f7fb"; font.pixelSize: 19; font.bold: true }
                Item { Layout.fillWidth: true }
                Text { text: "⌘⇧5"; color: "#697586"; font.pixelSize: 11 }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                Repeater {
                    model: [
                        { title: "Screen", glyph: "▣", command: "mkdir -p ~/Pictures/Screenshots; grim ~/Pictures/Screenshots/sn0w-$(date +%Y%m%d-%H%M%S).png" },
                        { title: "Area", glyph: "⌗", command: "mkdir -p ~/Pictures/Screenshots; grim -g \"$(slurp)\" ~/Pictures/Screenshots/sn0w-$(date +%Y%m%d-%H%M%S).png" },
                        { title: "Record", glyph: "●", command: "mkdir -p ~/Videos/Captures; wf-recorder -g \"$(slurp)\" -f ~/Videos/Captures/sn0w-$(date +%Y%m%d-%H%M%S).mp4 >/tmp/sn0w-wf-recorder.log 2>&1 &" }
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 12
                        color: mouse.containsMouse ? "#202936" : "#171c23"
                        border.width: 1
                        border.color: "#242c36"

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            Text { Layout.alignment: Qt.AlignHCenter; text: modelData.glyph; color: "#f4f7fb"; font.pixelSize: 24 }
                            Text { Layout.alignment: Qt.AlignHCenter; text: modelData.title; color: "#dce3ec"; font.pixelSize: 12; font.bold: true }
                        }

                        MouseArea {
                            id: mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: panel.run(modelData.command)
                        }
                    }
                }
            }

            Text {
                text: "Screenshots → ~/Pictures/Screenshots · recordings → ~/Videos/Captures"
                color: "#596474"
                font.pixelSize: 10
            }
        }
    }
}
