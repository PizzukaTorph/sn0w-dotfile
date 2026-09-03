import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: power

    implicitWidth: 320
    implicitHeight: 230
    radius: 18
    color: "#11151b"
    border.width: 1
    border.color: "#2b3440"

    function run(command: list<string>): void {
        actionProc.command = command;
        actionProc.running = true;
    }

    Process { id: actionProc }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        Text { text: "Power"; color: "#f4f7fb"; font.pixelSize: 19; font.bold: true }
        Text { text: "Session actions"; color: "#697586"; font.pixelSize: 11 }

        Repeater {
            model: [
                { title: "Lock", command: ["hyprlock"] },
                { title: "Suspend", command: ["systemctl", "suspend"] },
                { title: "Log out", command: ["hyprctl", "dispatch", "exit"] },
                { title: "Power off", command: ["systemctl", "poweroff"] }
            ]
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                radius: 9
                color: powerMouse.containsMouse ? "#1b222c" : "transparent"
                Text { anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter; text: modelData.title; color: "#f4f7fb"; font.pixelSize: 13 }
                MouseArea { id: powerMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: power.run(modelData.command) }
            }
        }
    }
}
