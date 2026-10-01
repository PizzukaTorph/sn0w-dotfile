import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

FloatingWindow {
    id: panel

    property var entries: []

    implicitWidth: 620
    implicitHeight: 430
    title: "sn0w Clipboard"
    color: "transparent"

    function refresh(): void {
        if (!listProc.running)
            listProc.running = true
    }

    onVisibleChanged: if (visible) refresh()

    Process {
        id: listProc
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().length > 0 ? text.trim().split("\n") : []
                panel.entries = lines.slice(0, 40)
            }
        }
    }

    Process { id: pasteProc }

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: "#11151b"
        border.width: 1
        border.color: "#2b3440"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Text { text: "Clipboard"; color: "#f4f7fb"; font.pixelSize: 19; font.bold: true }
                Item { Layout.fillWidth: true }
                Text { text: "⌘⇧V"; color: "#697586"; font.pixelSize: 11 }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: "#0b0d10"
                clip: true

                Flickable {
                    anchors.fill: parent
                    anchors.margins: 8
                    contentWidth: width
                    contentHeight: historyColumn.implicitHeight

                    Column {
                        id: historyColumn
                        width: parent.width
                        spacing: 4

                        Repeater {
                            model: panel.entries
                            delegate: Rectangle {
                                required property string modelData
                                width: historyColumn.width
                                height: 48
                                radius: 9
                                color: mouse.containsMouse ? "#1b222c" : "transparent"

                                property string entryId: modelData.split("\t")[0]
                                property string preview: modelData.indexOf("\t") >= 0 ? modelData.slice(modelData.indexOf("\t") + 1) : modelData

                                Text {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    verticalAlignment: Text.AlignVCenter
                                    text: parent.preview
                                    color: "#dce3ec"
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                }

                                MouseArea {
                                    id: mouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        pasteProc.command = ["sh", "-lc", "cliphist decode " + parent.entryId + " | wl-copy"]
                                        pasteProc.running = true
                                        panel.visible = false
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Text {
                text: panel.entries.length + " recent entries"
                color: "#596474"
                font.pixelSize: 10
            }
        }
    }
}
