import Quickshell
import QtQuick
import QtQuick.Layouts

FloatingWindow {
    id: overview

    title: "sn0w Overview"
    implicitWidth: 900
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
                        text: "Where you're working"
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
                    model: [
                        { title: "General", hint: "Everyday workspace" },
                        { title: "Project", hint: "Active development session" },
                        { title: "Activity", hint: "Media · Gaming · Social" },
                        { title: "Scratch", hint: "Temporary windows" }
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 16
                        color: overviewMouse.containsMouse ? "#1b222c" : "#14191f"
                        border.width: 1
                        border.color: "#29313c"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: modelData.title
                                    color: "#f4f7fb"
                                    font.pixelSize: 16
                                    font.bold: true
                                }

                                Item { Layout.fillWidth: true }

                                Rectangle {
                                    width: 8
                                    height: 8
                                    radius: 4
                                    color: "#7d8998"
                                }
                            }

                            Text {
                                text: modelData.hint
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

                                Text {
                                    anchors.centerIn: parent
                                    text: "live window preview"
                                    color: "#46515f"
                                    font.pixelSize: 10
                                }
                            }
                        }

                        MouseArea {
                            id: overviewMouse
                            anchors.fill: parent
                            hoverEnabled: true
                        }
                    }
                }
            }
        }
    }
}
