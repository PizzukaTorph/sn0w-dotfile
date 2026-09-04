import Quickshell
import QtQuick
import QtQuick.Layouts

FloatingWindow {
    id: switcher

    required property var hyprState
    property int selectedIndex: 0

    title: "sn0w App Switcher"
    implicitWidth: 720
    implicitHeight: 210
    color: "transparent"

    function ensureSelectedVisible(): void {
        if (hyprState.clients.length === 0 || appFlick.width <= 0)
            return

        const item = appRepeater.itemAt(selectedIndex)
        if (!item)
            return

        const left = item.x
        const right = item.x + item.width
        if (left < appFlick.contentX)
            appFlick.contentX = left
        else if (right > appFlick.contentX + appFlick.width)
            appFlick.contentX = Math.max(0, right - appFlick.width)
    }

    function cycle(): void {
        if (hyprState.clients.length === 0)
            return
        selectedIndex = (selectedIndex + 1) % hyprState.clients.length
        visible = true
        Qt.callLater(ensureSelectedVisible)
    }

    function resetAndShow(): void {
        selectedIndex = 0
        appFlick.contentX = 0
        visible = true
        Qt.callLater(ensureSelectedVisible)
    }

    function commitSelection(): void {
        if (hyprState.clients.length === 0) {
            visible = false
            return
        }
        const client = hyprState.clients[Math.min(selectedIndex, hyprState.clients.length - 1)]
        if (client && client.address)
            hyprState.focusClient(client.address)
        visible = false
    }

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: "#11151b"
        border.width: 0

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

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: hyprState.clients.length + " windows  ·  ⌘Tab cycles  ·  release ⌘ to switch"
                    color: "#697586"
                    font.pixelSize: 11
                }
            }

            Flickable {
                id: appFlick
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: appRow.implicitWidth
                contentHeight: height
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Row {
                    id: appRow
                    height: parent.height
                    spacing: 10

                    Repeater {
                        id: appRepeater
                        model: hyprState.clients

                        delegate: Rectangle {
                            required property var modelData
                            required property int index

                            width: {
                                const visibleCards = Math.max(1, Math.min(4, hyprState.clients.length))
                                const available = appFlick.width - appRow.spacing * (visibleCards - 1)
                                return Math.max(112, Math.min(150, available / visibleCards))
                            }
                            height: appRow.height
                            radius: 12
                            color: index === switcher.selectedIndex ? "#27313d" : (appMouse.containsMouse ? "#202731" : "#171c23")
                            border.width: index === switcher.selectedIndex ? 2 : 1
                            border.color: index === switcher.selectedIndex ? "#aeb9c7" : "#242c36"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 7

                                Rectangle {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 44
                                    Layout.preferredHeight: 44
                                    radius: 11
                                    color: "#29313c"

                                    Text {
                                        anchors.centerIn: parent
                                        text: (modelData.class || "?").substring(0, 1).toUpperCase()
                                        color: "#f4f7fb"
                                        font.pixelSize: 17
                                        font.bold: true
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.class || "Window"
                                    color: "#dce3ec"
                                    font.pixelSize: 11
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.title || ""
                                    color: "#697586"
                                    font.pixelSize: 9
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                }

                                Item {
                                    Layout.fillHeight: true
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "Workspace " + (modelData.workspace ? modelData.workspace.id : "?")
                                    color: "#596474"
                                    font.pixelSize: 9
                                }
                            }

                            MouseArea {
                                id: appMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    switcher.selectedIndex = index
                                    switcher.commitSelection()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
