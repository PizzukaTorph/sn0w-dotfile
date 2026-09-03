import Quickshell
import QtQuick
import QtQuick.Layouts

FloatingWindow {
    id: switcher

    required property var hyprState
    property int selectedIndex: 0

    title: "sn0w App Switcher"
    implicitWidth: 720
    implicitHeight: 210

    function cycle(): void {
        if (hyprState.clients.length === 0)
            return;
        selectedIndex = (selectedIndex + 1) % hyprState.clients.length;
        visible = true;
        commitTimer.restart();
    }

    function resetAndShow(): void {
        selectedIndex = 0;
        visible = true;
        commitTimer.restart();
    }

    function commitSelection(): void {
        if (hyprState.clients.length === 0) {
            visible = false;
            return;
        }
        const client = hyprState.clients[Math.min(selectedIndex, hyprState.clients.length - 1)];
        if (client && client.address)
            hyprState.focusClient(client.address);
        visible = false;
    }

    Timer {
        id: commitTimer
        interval: 650
        onTriggered: switcher.commitSelection()
    }

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
                Text { text: "Apps"; color: "#f4f7fb"; font.pixelSize: 17; font.bold: true }
                Item { Layout.fillWidth: true }
                Text { text: hyprState.clients.length + " windows  ·  ⌘Tab cycles"; color: "#697586"; font.pixelSize: 11 }
            }

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: appRow.implicitWidth
                contentHeight: height
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Row {
                    id: appRow
                    height: parent.height
                    spacing: 10

                    Repeater {
                        model: hyprState.clients

                        delegate: Rectangle {
                            required property var modelData
                            required property int index
                            width: 150
                            height: appRow.height
                            radius: 12
                            color: index === switcher.selectedIndex ? "#27313d" : (appMouse.containsMouse ? "#202731" : "#171c23")
                            border.width: index === switcher.selectedIndex ? 2 : 1
                            border.color: index === switcher.selectedIndex ? "#aeb9c7" : "#242c36"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 7

                                Rectangle {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 44
                                    Layout.preferredHeight: 44
                                    radius: 11
                                    color: "#29313c"
                                    Text {
                                        anchors.centerIn: parent
                                        text: (modelData.class || "?").substring(0, 1).toUpperCase()
                                        color: "#f4f7fb"
                                        font.pixelSize: 17
                                        font.bold: true
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.class || "Window"
                                    color: "#dce3ec"
                                    font.pixelSize: 11
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.title || ""
                                    color: "#697586"
                                    font.pixelSize: 9
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                }

                                Item { Layout.fillHeight: true }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "Workspace " + (modelData.workspace ? modelData.workspace.id : "?")
                                    color: "#596474"
                                    font.pixelSize: 9
                                }
                            }

                            MouseArea {
                                id: appMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    switcher.selectedIndex = index;
                                    switcher.commitSelection();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
