import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

FloatingWindow {
    id: overview

    required property var hyprState
    required property var projectState
    signal closeRequested()

    property string query: ""

    title: "sn0w Overview"
    implicitWidth: 1040
    implicitHeight: 640
    color: "transparent"

    function projectForWorkspace(name: string) {
        if (!projectState)
            return null
        const projects = projectState.projects || []
        for (let i = 0; i < projects.length; ++i) {
            if ((projects[i].workspace || "") === name)
                return projects[i]
        }
        return null
    }

    function windowMatches(client): bool {
        const needle = query.trim().toLowerCase()
        if (needle.length === 0)
            return true
        const workspace = client.workspace || {}
        const project = projectForWorkspace(workspace.name || "")
        const haystack = [
            client.class || "",
            client.initialClass || "",
            client.title || "",
            workspace.name || "",
            project ? project.name : "",
            project ? project.branch : ""
        ].join(" ").toLowerCase()
        return haystack.indexOf(needle) >= 0
    }

    function workspaceWindows(workspace): var {
        const clients = hyprState.clients || []
        const result = []
        for (let i = 0; i < clients.length; ++i) {
            const client = clients[i]
            if (client.workspace && client.workspace.id === workspace.id && windowMatches(client))
                result.push(client)
        }
        return result
    }

    function workspaceMatches(workspace): bool {
        if (workspaceWindows(workspace).length > 0)
            return true
        const needle = query.trim().toLowerCase()
        if (needle.length === 0)
            return true
        const project = projectForWorkspace(workspace.name || "")
        const haystack = ((workspace.name || "") + " " + (project ? project.name : "") + " " + (project ? project.branch : "")).toLowerCase()
        return haystack.indexOf(needle) >= 0
    }

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: "#11151b"
        border.width: 0

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 1

                    Text {
                        text: "Overview"
                        color: "#f4f7fb"
                        font.pixelSize: 22
                        font.bold: true
                    }

                    Text {
                        text: hyprState.workspaces.length + " workspaces · " + hyprState.clients.length + " windows"
                        color: "#697586"
                        font.pixelSize: 10
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.preferredWidth: 310
                    Layout.preferredHeight: 38
                    radius: 10
                    color: "#0b0f14"
                    border.width: 1
                    border.color: searchField.activeFocus ? "#46576a" : "#242c36"

                    TextField {
                        id: searchField
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        placeholderText: "Find window, workspace or project…"
                        color: "#f4f7fb"
                        font.pixelSize: 11
                        focus: true
                        background: Item {}
                        onTextChanged: overview.query = text

                        Keys.onEscapePressed: {
                            overview.closeRequested()
                        }
                    }
                }

                Text {
                    text: "⌘↑"
                    color: "#697586"
                    font.pixelSize: 11
                }
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
                    spacing: 10

                    Repeater {
                        model: hyprState.workspaces

                        delegate: Rectangle {
                            id: workspaceCard
                            required property var modelData
                            property var windows: overview.workspaceWindows(modelData)
                            property var project: overview.projectForWorkspace(modelData.name || "")
                            property bool matches: overview.workspaceMatches(modelData)

                            visible: matches
                            width: workspaceColumn.width
                            height: matches ? Math.max(122, 70 + windowFlow.implicitHeight) : 0
                            radius: 14
                            color: modelData.id === hyprState.activeWorkspace ? "#1a2028" : "#14191f"
                            border.width: 1
                            border.color: modelData.id === hyprState.activeWorkspace ? "#46576a" : "#242c36"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 9

                                RowLayout {
                                    Layout.fillWidth: true

                                    Rectangle {
                                        Layout.preferredWidth: 7
                                        Layout.preferredHeight: 7
                                        radius: 4
                                        color: workspaceCard.modelData.id === hyprState.activeWorkspace ? "#aeb9c7" : "#596474"
                                    }

                                    Text {
                                        text: workspaceCard.modelData.name && workspaceCard.modelData.name.length > 0
                                              ? workspaceCard.modelData.name
                                              : "Workspace " + workspaceCard.modelData.id
                                        color: "#f4f7fb"
                                        font.pixelSize: 13
                                        font.bold: true
                                    }

                                    Rectangle {
                                        visible: workspaceCard.project !== null
                                        Layout.preferredWidth: projectText.implicitWidth + 16
                                        Layout.preferredHeight: 22
                                        radius: 7
                                        color: "#202932"

                                        Text {
                                            id: projectText
                                            anchors.centerIn: parent
                                            text: workspaceCard.project ? workspaceCard.project.name + (workspaceCard.project.branch ? " · " + workspaceCard.project.branch : "") : ""
                                            color: "#9fb0c2"
                                            font.pixelSize: 9
                                        }
                                    }

                                    Text {
                                        text: workspaceCard.windows.length + " windows"
                                        color: "#697586"
                                        font.pixelSize: 9
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 62
                                        Layout.preferredHeight: 26
                                        radius: 8
                                        color: workspaceMouse.containsMouse ? "#29313c" : "#1b222c"

                                        Text {
                                            anchors.centerIn: parent
                                            text: workspaceCard.modelData.id === hyprState.activeWorkspace ? "Active" : "Open"
                                            color: "#dce3ec"
                                            font.pixelSize: 9
                                        }

                                        MouseArea {
                                            id: workspaceMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                hyprState.focusWorkspace(workspaceCard.modelData.id)
                                                overview.closeRequested()
                                            }
                                        }
                                    }
                                }

                                Flow {
                                    id: windowFlow
                                    Layout.fillWidth: true
                                    spacing: 7

                                    Repeater {
                                        model: workspaceCard.windows

                                        delegate: Rectangle {
                                            id: windowCard
                                            required property var modelData
                                            width: Math.min(275, Math.max(180, workspaceCard.width / Math.max(1, Math.min(3, workspaceCard.windows.length)) - 18))
                                            height: 62
                                            radius: 10
                                            color: windowMouse.containsMouse ? "#242d38" : "#0e1217"
                                            border.width: 1
                                            border.color: "#202630"

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.margins: 9
                                                spacing: 9

                                                Rectangle {
                                                    Layout.preferredWidth: 32
                                                    Layout.preferredHeight: 32
                                                    radius: 9
                                                    color: "#252d38"

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: (windowCard.modelData.class || "?").substring(0, 1).toUpperCase()
                                                        color: "#f4f7fb"
                                                        font.pixelSize: 13
                                                        font.bold: true
                                                    }
                                                }

                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 1

                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: windowCard.modelData.class || "Window"
                                                        color: "#dce3ec"
                                                        font.pixelSize: 10
                                                        font.bold: true
                                                        elide: Text.ElideRight
                                                    }

                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: windowCard.modelData.title || ""
                                                        color: "#697586"
                                                        font.pixelSize: 9
                                                        elide: Text.ElideRight
                                                    }
                                                }
                                            }

                                            MouseArea {
                                                id: windowMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    hyprState.focusClient(windowCard.modelData.address || "")
                                                    overview.closeRequested()
                                                }
                                            }
                                        }
                                    }
                                }

                                Text {
                                    visible: workspaceCard.windows.length === 0
                                    text: overview.query.length > 0 ? "No matching windows" : "Empty workspace"
                                    color: "#46515f"
                                    font.pixelSize: 9
                                }
                            }
                        }
                    }
                }
            }

            Text {
                visible: overview.query.length > 0 && workspaceColumn.implicitHeight === 0
                Layout.alignment: Qt.AlignHCenter
                text: "No matching workspace or window"
                color: "#596474"
                font.pixelSize: 10
            }
        }
    }
}
