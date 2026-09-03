import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

FloatingWindow {
    id: launcher

    title: "sn0w launcher"
    implicitWidth: 680
    implicitHeight: 460
    color: "#11151b"

    function matches(entry): bool {
        const needle = query.text.trim().toLowerCase();
        if (needle.length === 0)
            return true;

        return entry.name.toLowerCase().includes(needle)
            || entry.genericName.toLowerCase().includes(needle)
            || entry.comment.toLowerCase().includes(needle);
    }

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: "#11151b"
        border.width: 1
        border.color: "#2b3440"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 22
            spacing: 14

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "sn0w"
                    color: "#f4f7fb"
                    font.pixelSize: 22
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "Launcher"
                    color: "#697586"
                    font.pixelSize: 12
                }
            }

            TextField {
                id: query
                Layout.fillWidth: true
                placeholderText: "Apps, projects, actions…"
                font.pixelSize: 16
                focus: launcher.visible
                selectByMouse: true
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
                    contentHeight: appColumn.implicitHeight
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: appColumn
                        width: parent.width
                        spacing: 4

                        Repeater {
                            model: DesktopEntries.applications

                            delegate: Rectangle {
                                required property var modelData
                                width: appColumn.width
                                height: launcher.matches(modelData) ? 52 : 0
                                visible: launcher.matches(modelData)
                                radius: 9
                                color: mouse.containsMouse ? "#1b222c" : "transparent"
                                clip: true

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 12

                                    Image {
                                        source: modelData.icon.length > 0
                                            ? Quickshell.iconPath(modelData.icon)
                                            : ""
                                        sourceSize.width: 30
                                        sourceSize.height: 30
                                        Layout.preferredWidth: 30
                                        Layout.preferredHeight: 30
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1

                                        Text {
                                            text: modelData.name
                                            color: "#f4f7fb"
                                            font.pixelSize: 14
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        Text {
                                            text: modelData.genericName.length > 0
                                                ? modelData.genericName
                                                : modelData.comment
                                            color: "#697586"
                                            font.pixelSize: 11
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                    }
                                }

                                MouseArea {
                                    id: mouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        modelData.execute();
                                        launcher.visible = false;
                                        query.clear();
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Text {
                text: "⌘Space toggle · desktop entries live from Quickshell"
                color: "#697586"
                font.pixelSize: 11
            }
        }
    }
}
