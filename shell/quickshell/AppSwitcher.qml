import Quickshell
import QtQuick
import QtQuick.Layouts

FloatingWindow {
    id: switcher

    title: "sn0w App Switcher"
    implicitWidth: 620
    implicitHeight: 190

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: "#11151b"
        border.width: 1
        border.color: "#2b3440"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Apps"
                    color: "#f4f7fb"
                    font.pixelSize: 17
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "⌘Tab"
                    color: "#697586"
                    font.pixelSize: 11
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                Repeater {
                    model: ["Terminal", "Files", "Code", "Browser"]

                    delegate: Rectangle {
                        required property string modelData
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 12
                        color: appMouse.containsMouse ? "#202731" : "#171c23"
                        border.width: 1
                        border.color: "#242c36"

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 6

                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                width: 42
                                height: 42
                                radius: 11
                                color: "#29313c"

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.substring(0, 1)
                                    color: "#f4f7fb"
                                    font.pixelSize: 17
                                    font.bold: true
                                }
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData
                                color: "#dce3ec"
                                font.pixelSize: 11
                            }
                        }

                        MouseArea {
                            id: appMouse
                            anchors.fill: parent
                            hoverEnabled: true
                        }
                    }
                }
            }
        }
    }
}
