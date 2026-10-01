import Quickshell
import QtQuick
import QtQuick.Layouts

FloatingWindow {
    id: osd

    property string kind: "volume"
    property int value: 0
    property bool muted: false

    implicitWidth: 300
    implicitHeight: 82
    visible: false
    title: "sn0w OSD"

    function showValue(nextKind: string, nextValue: int, nextMuted: bool): void {
        kind = nextKind;
        value = Math.max(0, Math.min(100, nextValue));
        muted = nextMuted;
        visible = true;
        hideTimer.restart();
    }

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: "#ee11151b"
        border.width: 1
        border.color: "#2b3440"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14

            Text {
                text: osd.kind === "brightness" ? "☀" : (osd.muted ? "⊘" : "♪")
                color: "#f4f7fb"
                font.pixelSize: 22
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 7

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: osd.kind === "brightness" ? "Brightness" : (osd.muted ? "Muted" : "Volume")
                        color: "#e7ecf3"
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: osd.value + "%"
                        color: "#8f9baa"
                        font.pixelSize: 11
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 6
                    radius: 3
                    color: "#29313c"
                    Rectangle {
                        width: parent.width * osd.value / 100
                        height: parent.height
                        radius: 3
                        color: "#c6d0dc"
                    }
                }
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 1200
        onTriggered: osd.visible = false
    }
}
