import Quickshell
import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    required property var catalog
    property bool shown: true

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: cheatWindow
            required property var modelData

            screen: modelData
            visible: root.shown

            anchors {
                right: true
                bottom: true
            }

            margins {
                right: 24
                bottom: 24
            }

            implicitWidth: 356
            implicitHeight: content.implicitHeight + 28

            // This is a desktop aid, not a panel: tiled/floating application
            // windows must always cover it and it must not reserve screen area.
            aboveWindows: false
            exclusionMode: ExclusionMode.Ignore
            focusable: false
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                radius: 16
                color: "#d911151b"
                border.width: 1
                border.color: "#2b3440"

                ColumnLayout {
                    id: content
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 14
                    spacing: 9

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "sn0w"
                            color: "#f4f7fb"
                            font.pixelSize: 15
                            font.bold: true
                        }

                        Text {
                            text: "shortcuts"
                            color: "#7f8b99"
                            font.pixelSize: 11
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "quick reference"
                            color: "#566271"
                            font.pixelSize: 9
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: "#252d37"
                    }

                    Repeater {
                        model: root.catalog ? root.catalog.quickGroups : []

                        delegate: ColumnLayout {
                            required property var modelData
                            Layout.fillWidth: true
                            spacing: 5

                            Text {
                                text: modelData.title
                                color: "#7f8b99"
                                font.pixelSize: 9
                                font.bold: true
                            }

                            Repeater {
                                model: modelData.items

                                delegate: RowLayout {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    spacing: 10

                                    Text {
                                        Layout.preferredWidth: 132
                                        text: modelData.keys
                                        color: "#e6ebf1"
                                        font.pixelSize: 10
                                        font.family: "monospace"
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.action
                                        color: "#9ba7b5"
                                        font.pixelSize: 10
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }
                    }

                    Item {
                        Layout.preferredHeight: 1
                    }
                }
            }
        }
    }
}
