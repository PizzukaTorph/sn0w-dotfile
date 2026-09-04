import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

FloatingWindow {
    id: window

    required property var settingsState

    title: "sn0w Settings"
    implicitWidth: 700
    implicitHeight: 560

    Rectangle {
        anchors.fill: parent
        radius: 20
        color: "#11151b"
        border.width: 1
        border.color: "#2b3440"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 1

                    Text {
                        text: "Settings"
                        color: "#f4f7fb"
                        font.pixelSize: 21
                        font.bold: true
                    }

                    Text {
                        text: "~/.config/sn0w/settings.json"
                        color: "#697586"
                        font.pixelSize: 10
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.preferredWidth: 74
                    Layout.preferredHeight: 30
                    radius: 8
                    color: saveMouse.containsMouse ? "#334150" : "#27313d"

                    Text {
                        anchors.centerIn: parent
                        text: "Save"
                        color: "#f4f7fb"
                        font.pixelSize: 11
                        font.bold: true
                    }

                    MouseArea {
                        id: saveMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            settingsState.terminal = terminalField.text.trim()
                            settingsState.fileManager = filesField.text.trim()
                            settingsState.editor = editorField.text.trim()
                            settingsState.screenshotsDir = screenshotsField.text.trim()
                            settingsState.recordingsDir = recordingsField.text.trim()
                            settingsState.save()
                        }
                    }
                }
            }

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: width
                contentHeight: settingsColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: settingsColumn
                    width: parent.width
                    spacing: 12

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: projectColumn.implicitHeight + 28
                        radius: 12
                        color: "#171c23"
                        border.width: 1
                        border.color: "#242c36"

                        ColumnLayout {
                            id: projectColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 14
                            spacing: 8

                            Text {
                                text: "Project folders"
                                color: "#f4f7fb"
                                font.pixelSize: 13
                                font.bold: true
                            }

                            Repeater {
                                model: settingsState.projectRoots

                                delegate: RowLayout {
                                    required property string modelData
                                    required property int index
                                    Layout.fillWidth: true
                                    spacing: 8

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData
                                        color: "#cbd3dd"
                                        font.pixelSize: 11
                                        elide: Text.ElideMiddle
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 62
                                        Layout.preferredHeight: 26
                                        radius: 7
                                        color: rootRemoveMouse.containsMouse ? "#342128" : "#20262e"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "Remove"
                                            color: "#aeb8c5"
                                            font.pixelSize: 9
                                        }

                                        MouseArea {
                                            id: rootRemoveMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: settingsState.removeProjectRoot(index)
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                TextField {
                                    id: projectRootField
                                    Layout.fillWidth: true
                                    placeholderText: "~/Code or /mnt/projects"
                                    color: "#f4f7fb"
                                    font.pixelSize: 11
                                    background: Rectangle {
                                        radius: 8
                                        color: "#0d1116"
                                        border.width: 1
                                        border.color: "#28313c"
                                    }
                                }

                                Button {
                                    text: "+ Add"
                                    onClicked: {
                                        settingsState.addProjectRoot(projectRootField.text)
                                        projectRootField.clear()
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: sshColumn.implicitHeight + 28
                        radius: 12
                        color: "#171c23"
                        border.width: 1
                        border.color: "#242c36"

                        ColumnLayout {
                            id: sshColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 14
                            spacing: 8

                            Text {
                                text: "SSH hosts"
                                color: "#f4f7fb"
                                font.pixelSize: 13
                                font.bold: true
                            }

                            Repeater {
                                model: settingsState.sshHosts

                                delegate: RowLayout {
                                    required property string modelData
                                    required property int index
                                    Layout.fillWidth: true
                                    spacing: 8

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData
                                        color: "#cbd3dd"
                                        font.pixelSize: 11
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 62
                                        Layout.preferredHeight: 26
                                        radius: 7
                                        color: hostRemoveMouse.containsMouse ? "#342128" : "#20262e"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "Remove"
                                            color: "#aeb8c5"
                                            font.pixelSize: 9
                                        }

                                        MouseArea {
                                            id: hostRemoveMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: settingsState.removeSshHost(index)
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                TextField {
                                    id: sshHostField
                                    Layout.fillWidth: true
                                    placeholderText: "hostname or SSH config alias"
                                    color: "#f4f7fb"
                                    font.pixelSize: 11
                                    background: Rectangle {
                                        radius: 8
                                        color: "#0d1116"
                                        border.width: 1
                                        border.color: "#28313c"
                                    }
                                }

                                Button {
                                    text: "+ Add"
                                    onClicked: {
                                        settingsState.addSshHost(sshHostField.text)
                                        sshHostField.clear()
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: appsGrid.implicitHeight + 54
                        radius: 12
                        color: "#171c23"
                        border.width: 1
                        border.color: "#242c36"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 8

                            Text {
                                text: "Default applications"
                                color: "#f4f7fb"
                                font.pixelSize: 13
                                font.bold: true
                            }

                            GridLayout {
                                id: appsGrid
                                Layout.fillWidth: true
                                columns: 2
                                columnSpacing: 10
                                rowSpacing: 8

                                Text {
                                    text: "Terminal"
                                    color: "#8f9aaa"
                                    font.pixelSize: 10
                                }
                                TextField {
                                    id: terminalField
                                    Layout.fillWidth: true
                                    text: settingsState.terminal
                                    color: "#f4f7fb"
                                    font.pixelSize: 11
                                }
                                Text {
                                    text: "File manager"
                                    color: "#8f9aaa"
                                    font.pixelSize: 10
                                }
                                TextField {
                                    id: filesField
                                    Layout.fillWidth: true
                                    text: settingsState.fileManager
                                    color: "#f4f7fb"
                                    font.pixelSize: 11
                                }
                                Text {
                                    text: "Editor"
                                    color: "#8f9aaa"
                                    font.pixelSize: 10
                                }
                                TextField {
                                    id: editorField
                                    Layout.fillWidth: true
                                    text: settingsState.editor
                                    color: "#f4f7fb"
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: captureGrid.implicitHeight + 54
                        radius: 12
                        color: "#171c23"
                        border.width: 1
                        border.color: "#242c36"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 8

                            Text {
                                text: "Capture folders"
                                color: "#f4f7fb"
                                font.pixelSize: 13
                                font.bold: true
                            }

                            GridLayout {
                                id: captureGrid
                                Layout.fillWidth: true
                                columns: 2
                                columnSpacing: 10
                                rowSpacing: 8

                                Text {
                                    text: "Screenshots"
                                    color: "#8f9aaa"
                                    font.pixelSize: 10
                                }
                                TextField {
                                    id: screenshotsField
                                    Layout.fillWidth: true
                                    text: settingsState.screenshotsDir
                                    color: "#f4f7fb"
                                    font.pixelSize: 11
                                }
                                Text {
                                    text: "Recordings"
                                    color: "#8f9aaa"
                                    font.pixelSize: 10
                                }
                                TextField {
                                    id: recordingsField
                                    Layout.fillWidth: true
                                    text: settingsState.recordingsDir
                                    color: "#f4f7fb"
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
