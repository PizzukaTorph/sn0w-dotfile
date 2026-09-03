import Quickshell
import QtQuick
import QtQuick.Layouts

FloatingWindow {
    id: panel

    required property var projectState

    title: "sn0w Project Center"
    implicitWidth: 820
    implicitHeight: 520

    Rectangle {
        anchors.fill: parent
        radius: 20
        color: "#11151b"
        border.width: 1
        border.color: "#2b3440"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                ColumnLayout {
                    spacing: 1
                    Text { text: "Project Center"; color: "#f4f7fb"; font.pixelSize: 22; font.bold: true }
                    Text { text: projectState.projects.length + " detected Git projects"; color: "#697586"; font.pixelSize: 11 }
                }
                Item { Layout.fillWidth: true }
                Text { text: "sn0w"; color: "#596474"; font.pixelSize: 11 }
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
                                required property var modelData
                                width: projectColumn.width
                                height: 72
                                radius: 11
                                color: projectMouse.containsMouse ? "#1b222c" : "#14191f"
                                border.width: 1
                                border.color: "#242c36"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Rectangle {
                                        Layout.preferredWidth: 38
                                        Layout.preferredHeight: 38
                                        radius: 10
                                        color: "#252d38"
                                        Text { anchors.centerIn: parent; text: "◆"; color: "#dce3ec"; font.pixelSize: 14 }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        Text { text: modelData.name; color: "#f4f7fb"; font.pixelSize: 14; font.bold: true }
                                        Text { Layout.fillWidth: true; text: modelData.path; color: "#697586"; font.pixelSize: 10; elide: Text.ElideMiddle }
                                    }

                                    Repeater {
                                        model: ["Code", "Terminal", "Files"]
                                        delegate: Rectangle {
                                            required property string modelData
                                            Layout.preferredWidth: 66
                                            Layout.preferredHeight: 30
                                            radius: 8
                                            color: actionMouse.containsMouse ? "#29313c" : "#1b222c"
                                            Text { anchors.centerIn: parent; text: modelData; color: "#dce3ec"; font.pixelSize: 10 }
                                            MouseArea {
                                                id: actionMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (modelData === "Code") projectState.openCode(parent.parent.parent.parent.modelData.path);
                                                    else if (modelData === "Terminal") projectState.openTerminal(parent.parent.parent.parent.modelData.path);
                                                    else projectState.openFiles(parent.parent.parent.parent.modelData.path);
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
                text: "No Git projects detected in ~/Code, ~/Projects, ~/Dev or /mnt"
                color: "#596474"
                font.pixelSize: 11
            }
        }
    }
}
