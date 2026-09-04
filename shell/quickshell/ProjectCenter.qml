import Quickshell
import QtQuick
import QtQuick.Layouts

FloatingWindow {
    id: panel

    required property var projectState

    title: "sn0w Project Center"
    implicitWidth: 860
    implicitHeight: 540
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        radius: 12
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
                        text: "Project Center"
                        color: "#f4f7fb"
                        font.pixelSize: 22
                        font.bold: true
                    }

                    Text {
                        text: projectState.projects.length + " detected Git projects"
                        color: "#697586"
                        font.pixelSize: 11
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: projectState.actionStatus
                    color: "#8f9aaa"
                    font.pixelSize: 10
                }
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
                    contentHeight: projectColumn.implicitHeight
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: projectColumn
                        width: parent.width
                        spacing: 6

                        Repeater {
                            model: projectState.projects

                            delegate: Rectangle {
                                id: projectCard
                                required property var modelData
                                property bool sessionRunning: modelData.session && modelData.session.running === true
                                width: projectColumn.width
                                height: 84
                                radius: 11
                                color: projectMouse.containsMouse ? "#1b222c" : "#14191f"
                                border.width: 1
                                border.color: "#242c36"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 10

                                    Rectangle {
                                        Layout.preferredWidth: 38
                                        Layout.preferredHeight: 38
                                        radius: 10
                                        color: projectCard.sessionRunning ? "#26352e" : "#252d38"

                                        Text {
                                            anchors.centerIn: parent
                                            text: projectCard.sessionRunning ? "●" : "◆"
                                            color: "#dce3ec"
                                            font.pixelSize: 14
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        RowLayout {
                                            Text {
                                                text: projectCard.modelData.name
                                                color: "#f4f7fb"
                                                font.pixelSize: 14
                                                font.bold: true
                                            }

                                            Text {
                                                text: projectCard.modelData.branch ? "  " + projectCard.modelData.branch + (projectCard.modelData.dirty ? " *" : "") : ""
                                                color: "#8f9aaa"
                                                font.pixelSize: 10
                                            }
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: projectCard.modelData.path
                                            color: "#697586"
                                            font.pixelSize: 10
                                            elide: Text.ElideMiddle
                                        }

                                        Text {
                                            text: projectCard.sessionRunning ? "Session running" : "Session stopped"
                                            color: projectCard.sessionRunning ? "#8fb69d" : "#596474"
                                            font.pixelSize: 9
                                        }
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 58
                                        Layout.preferredHeight: 30
                                        radius: 8
                                        color: sessionMouse.containsMouse ? "#303946" : "#222a34"

                                        Text {
                                            anchors.centerIn: parent
                                            text: projectCard.sessionRunning ? "Stop" : "Start"
                                            color: "#f4f7fb"
                                            font.pixelSize: 10
                                            font.bold: true
                                        }

                                        MouseArea {
                                            id: sessionMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (projectCard.sessionRunning)
                                                    projectState.stopProject(projectCard.modelData.path)
                                                else
                                                    projectState.startProject(projectCard.modelData.path)
                                            }
                                        }
                                    }

                                    Repeater {
                                        model: ["Code", "Terminal", "Files"]

                                        delegate: Rectangle {
                                            required property string modelData
                                            Layout.preferredWidth: 62
                                            Layout.preferredHeight: 30
                                            radius: 8
                                            color: actionMouse.containsMouse ? "#29313c" : "#1b222c"

                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData
                                                color: "#dce3ec"
                                                font.pixelSize: 10
                                            }

                                            MouseArea {
                                                id: actionMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (modelData === "Code")
                                                        projectState.openCode(projectCard.modelData.path)
                                                    else if (modelData === "Terminal")
                                                        projectState.openTerminal(projectCard.modelData.path)
                                                    else
                                                        projectState.openFiles(projectCard.modelData.path)
                                                }
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    id: projectMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.NoButton
                                }
                            }
                        }
                    }
                }
            }

            Text {
                visible: projectState.projects.length === 0
                Layout.alignment: Qt.AlignHCenter
                text: "No Git projects detected in configured project folders"
                color: "#596474"
                font.pixelSize: 11
            }
        }
    }
}
