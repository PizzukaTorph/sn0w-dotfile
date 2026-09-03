import Quickshell
import QtQuick
import QtQuick.Layouts

FloatingWindow {
    id: overview

    required property var hyprState

    title: "sn0w Overview"
    implicitWidth: 920
    implicitHeight: 560

    Rectangle {
        anchors.fill: parent
        color: "#f20b0d10"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 18

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 2

                    Text {
                        text: "Overview"
                        color: "#f4f7fb"
                        font.pixelSize: 24
                        font.bold: true
                    }

                    Text {
                        text: hyprState.workspaces.length + " active workspaces · " + hyprState.clients.length + " windows"
                        color: "#7d8998"
                        font.pixelSize: 12
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "⌘↑"
                    color: "#697586"
                    font.pixelSize: 12
                }
            }

            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 2
                columnSpacing: 16
                rowSpacing: 16

                Repeater {
                    model: hyprState.workspaces

                    delegate: Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 160
                        radius: 16
                        color: modelData.id === hyprState.activeWorkspace
                            ? "#1b222c"
                            : (overviewMouse.containsMouse ? "#181e25" : "#14191f")
                        border.width: modelData.id === hyprState.activeWorkspace ? 2 : 1
                        border.color: modelData.id === hyprState.activeWorkspace ? "#657283" : "#29313c"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: modelData.name && modelData.name.length > 0
                                        ? modelData.name
                                        : "Workspace " + modelData.id
                                    color: "#f4f7fb"
                                    font.pixelSize: 16
                                    font.bold: true
                                }

                                Item { Layout.fillWidth: true }

                                Rectangle {
                                    width: 8
                                    height: 8
                                    radius: 4
                                    color: modelData.id === hyprState.activeWorkspace ? "#dce3ec" : "#596474"
                                }
                            }

                            Text {
                                text: (modelData.windows || 0) + " windows"
                                color: "#697586"
                                font.pixelSize: 11
                            }

                            Item { Layout.fillHeight: true }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 88
                                radius: 10
                                color: "#0e1217"
                                border.width: 1
                                border.color: "#202630"

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 4

                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: modelData.id === hyprState.activeWorkspace ? "ACTIVE" : "OPEN"
                                        color: modelData.id === hyprState.activeWorkspace ? "#dce3ec" : "#697586"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }

                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: "Workspace " + modelData.id
                                        color: "#46515f"
                                        font.pixelSize: 10
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: overviewMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                hyprState.focusWorkspace(modelData.id);
                                overview.visible = false;
                            }
                        }
                    }
                }
            }

            Text {
                visible: hyprState.workspaces.length === 0
                Layout.alignment: Qt.AlignHCenter
                text: "No Hyprland workspaces reported"
                color: "#596474"
                font.pixelSize: 11
            }
        }
    }
}
