import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

FloatingWindow {
    id: launcher

    title: "sn0w Launcher"
    implicitWidth: 700
    implicitHeight: 500

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

                    Text {
                        text: "sn0w"
                        color: "#f4f7fb"
                        font.pixelSize: 22
                        font.bold: true
                    }

                    Text {
                        text: "Launcher"
                        color: "#697586"
                        font.pixelSize: 11
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    Layout.preferredWidth: 62
                    Layout.preferredHeight: 24
                    radius: 8
                    color: "#171c23"
                    border.width: 1
                    border.color: "#242c36"

                    Text {
                        anchors.centerIn: parent
                        text: "⌘ Space"
                        color: "#8f9aaa"
                        font.pixelSize: 10
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                radius: 12
                color: "#0c1015"
                border.width: 1
                border.color: query.activeFocus ? "#3a4655" : "#202630"

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                    text: "⌕"
                    color: "#697586"
                    font.pixelSize: 19
                }

                TextField {
                    id: query
                    anchors.fill: parent
                    anchors.leftMargin: 42
                    anchors.rightMargin: 10
                    placeholderText: "Apps, projects, actions…"
                    color: "#f4f7fb"
                    font.pixelSize: 16
                    focus: launcher.visible
                    selectByMouse: true
                    background: Item {}
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: query.text.length === 0 ? "Applications" : "Results"
                    color: "#9aa5b4"
                    font.pixelSize: 11
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "desktop entries"
                    color: "#596474"
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
                                height: launcher.matches(modelData) ? 54 : 0
                                visible: launcher.matches(modelData)
                                radius: 10
                                color: mouse.containsMouse ? "#1b222c" : "transparent"
                                clip: true

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 12

                                    Rectangle {
                                        Layout.preferredWidth: 36
                                        Layout.preferredHeight: 36
                                        radius: 9
                                        color: "#202731"

                                        Image {
                                            anchors.centerIn: parent
                                            source: modelData.icon.length > 0
                                                ? Quickshell.iconPath(modelData.icon)
                                                : ""
                                            sourceSize.width: 26
                                            sourceSize.height: 26
                                            width: 26
                                            height: 26
                                        }
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

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Enter launch · Esc close"
                    color: "#596474"
                    font.pixelSize: 10
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "Projects + actions next"
                    color: "#596474"
                    font.pixelSize: 10
                }
            }
        }
    }
}
