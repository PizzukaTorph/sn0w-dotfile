import Quickshell
import QtQuick
import QtQuick.Layouts

FloatingWindow {
    id: overview

    required property var hyprState

    title: "sn0w Overview"
    implicitWidth: 980
    implicitHeight: 620

    Rectangle {
        anchors.fill: parent
        radius: 22
        color: "#f20b0d10"
        border.width: 1
        border.color: "#202630"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 18

            RowLayout {
                Layout.fillWidth: true
                ColumnLayout {
                    spacing: 2
                    Text { text: "Overview"; color: "#f4f7fb"; font.pixelSize: 24; font.bold: true }
                    Text { text: hyprState.workspaces.length + " workspaces · " + hyprState.clients.length + " app windows"; color: "#7d8998"; font.pixelSize: 12 }
                }
                Item { Layout.fillWidth: true }
                Text { text: "⌘↑"; color: "#697586"; font.pixelSize: 12 }
            }

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: width
                contentHeight: workspaceColumn.implicitHeight
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                Column {
                    id: workspaceColumn
                    width: parent.width
                    spacing: 12

                    Repeater {
                        model: hyprState.workspaces

                        delegate: Rectangle {
                            id: workspaceCard
                            required property var modelData
                            property var windows: hyprState.clients.filter(c => c.workspace && c.workspace.id === modelData.id)
                            width: workspaceColumn.width
                            height: Math.max(138, 86 + windowRow.implicitHeight)
                            radius: 16
                            color: modelData.id === hyprState.activeWorkspace ? "#1b222c" : "#14191f"
                            border.width: modelData.id === hyprState.activeWorkspace ? 2 : 1
                            border.color: modelData.id === hyprState.activeWorkspace ? "#657283" : "#29313c"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 10

                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: modelData.name && modelData.name.length > 0 ? modelData.name : "Workspace " + modelData.id
                                        color: "#f4f7fb"
                                        font.pixelSize: 15
                                        font.bold: true
                                    }
                                    Rectangle { width: 7; height: 7; radius: 4; color: modelData.id === hyprState.activeWorkspace ? "#dce3ec" : "#596474" }
                                    Text { text: workspaceCard.windows.length + " windows"; color: "#697586"; font.pixelSize: 10 }
                                    Item { Layout.fillWidth: true }
                                    Rectangle {
                                        Layout.preferredWidth: 72
                                        Layout.preferredHeight: 28
                                        radius: 8
                                        color: workspaceMouse.containsMouse ? "#29313c" : "#1b222c"
                                        Text { anchors.centerIn: parent; text: modelData.id === hyprState.activeWorkspace ? "Active" : "Open"; color: "#dce3ec"; font.pixelSize: 10 }
                                        MouseArea {
                                            id: workspaceMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                hyprState.focusWorkspace(workspaceCard.modelData.id);
                                                overview.visible = false;
                                            }
                                        }
                                    }
                                }

                                Flow {
                                    id: windowRow
                                    Layout.fillWidth: true
                                    spacing: 8

                                    Repeater {
                                        model: workspaceCard.windows

                                        delegate: Rectangle {
                                            id: windowCard
                                            required property var modelData
                                            width: Math.min(260, Math.max(180, workspaceCard.width / Math.max(1, Math.min(3, workspaceCard.windows.length)) - 20))
                                            height: 68
                                            radius: 10
                                            color: windowMouse.containsMouse ? "#242d38" : "#0e1217"
                                            border.width: 1
                                            border.color: "#202630"

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.margins: 10
                                                spacing: 9
                                                Rectangle {
                                                    Layout.preferredWidth: 34
                                                    Layout.preferredHeight: 34
                                                    radius: 9
                                                    color: "#252d38"
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: (modelData.class || "?").substring(0, 1).toUpperCase()
                                                        color: "#f4f7fb"
                                                        font.pixelSize: 14
                                                        font.bold: true
                                                    }
                                                }
                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 2
                                                    Text { Layout.fillWidth: true; text: modelData.class || "Window"; color: "#dce3ec"; font.pixelSize: 11; font.bold: true; elide: Text.ElideRight }
                                                    Text { Layout.fillWidth: true; text: modelData.title || ""; color: "#697586"; font.pixelSize: 9; elide: Text.ElideRight }
                                                }
                                            }

                                            MouseArea {
                                                id: windowMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    hyprState.focusClient(windowCard.modelData.address || "");
                                                    overview.visible = false;
                                                }
                                            }
                                        }
                                    }
                                }

                                Text {
                                    visible: workspaceCard.windows.length === 0
                                    text: "Empty workspace"
                                    color: "#46515f"
                                    font.pixelSize: 10
                                }
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
