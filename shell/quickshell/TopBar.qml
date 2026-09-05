import Quickshell
import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    property string mode: "General"
    property var systemState
    property var projectState
    signal launcherRequested()
    signal projectCenterRequested()

    function activeServiceSummary(): string {
        if (!projectState || !projectState.activeProject)
            return ""

        const services = projectState.activeProject.services || []
        if (services.length === 0)
            return ""

        let running = 0
        let unhealthy = 0
        for (let i = 0; i < services.length; ++i) {
            if ((services[i].state || "").toLowerCase() === "running")
                running++

            const health = (services[i].health || "").toLowerCase()
            if (health.length > 0 && health !== "healthy")
                unhealthy++
        }

        if (unhealthy > 0)
            return running + "/" + services.length + " · " + unhealthy + " unhealthy"
        return running + "/" + services.length + " services"
    }

    function projectHealthy(): bool {
        if (!projectState || !projectState.activeProject)
            return true
        const services = projectState.activeProject.services || []
        for (let i = 0; i < services.length; ++i) {
            const health = (services[i].health || "").toLowerCase()
            if (health.length > 0 && health !== "healthy")
                return false
        }
        return true
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 38
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: "#f20b0d10"
                border.width: 0

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    color: "#202630"
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 10
                    spacing: 7

                    Rectangle {
                        Layout.preferredWidth: brandRow.implicitWidth + 18
                        Layout.preferredHeight: 27
                        radius: 9
                        color: brandMouse.containsMouse ? "#1b222c" : "transparent"

                        RowLayout {
                            id: brandRow
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: "sn0w"
                                color: "#f4f7fb"
                                font.pixelSize: 14
                                font.bold: true
                            }

                            Rectangle {
                                width: 4
                                height: 4
                                radius: 2
                                color: "#7d8998"
                            }

                            Text {
                                text: root.mode
                                color: "#9aa5b4"
                                font.pixelSize: 11
                            }
                        }

                        MouseArea {
                            id: brandMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.launcherRequested()
                        }
                    }

                    Rectangle {
                        id: projectButton
                        visible: root.projectState && root.projectState.activeProject
                        Layout.preferredWidth: Math.min(520, projectRow.implicitWidth + 18)
                        Layout.preferredHeight: 27
                        radius: 9
                        color: projectMouse.containsMouse ? "#1b222c" : "#141a20"
                        border.width: 1
                        border.color: root.projectHealthy() ? "#253a32" : "#4a2f34"

                        RowLayout {
                            id: projectRow
                            anchors.centerIn: parent
                            spacing: 7

                            Rectangle {
                                width: 6
                                height: 6
                                radius: 3
                                color: root.projectHealthy() ? "#8fb69d" : "#d98c8c"
                            }

                            Text {
                                text: root.projectState && root.projectState.activeProject ? root.projectState.activeProject.name : ""
                                color: "#edf2f7"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            Text {
                                visible: root.projectState && root.projectState.activeProject && root.projectState.activeProject.branch
                                text: root.projectState && root.projectState.activeProject
                                      ? root.projectState.activeProject.branch + (root.projectState.activeProject.dirty ? " *" : "")
                                      : ""
                                color: "#8f9aaa"
                                font.pixelSize: 9
                            }

                            Text {
                                visible: root.activeServiceSummary().length > 0
                                text: root.activeServiceSummary()
                                color: root.projectHealthy() ? "#697586" : "#c58f98"
                                font.pixelSize: 9
                            }
                        }

                        MouseArea {
                            id: projectMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.projectCenterRequested()
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        visible: root.systemState && root.systemState.vpnName !== "Off"
                        Layout.preferredWidth: vpnText.implicitWidth + 14
                        Layout.preferredHeight: 23
                        radius: 7
                        color: "#18231f"

                        Text {
                            id: vpnText
                            anchors.centerIn: parent
                            text: "VPN · " + (root.systemState ? root.systemState.vpnName : "")
                            color: "#8fb69d"
                            font.pixelSize: 9
                        }
                    }

                    Text {
                        visible: root.systemState !== undefined && root.systemState !== null
                        text: root.systemState && root.systemState.wifiEnabled
                              ? (root.systemState.wifiName === "Disconnected" ? "Wi-Fi" : root.systemState.wifiName)
                              : "Wi-Fi off"
                        color: "#8f9aaa"
                        font.pixelSize: 9
                    }

                    Text {
                        visible: root.systemState !== undefined && root.systemState !== null
                        text: root.systemState ? root.systemState.battery : ""
                        color: "#8f9aaa"
                        font.pixelSize: 9
                    }

                    Rectangle {
                        id: controlButton
                        Layout.preferredWidth: clockText.implicitWidth + 16
                        Layout.preferredHeight: 27
                        radius: 9
                        color: controlMouse.containsMouse || controlPopup.visible ? "#1b222c" : "transparent"

                        Text {
                            id: clockText
                            anchors.centerIn: parent
                            text: Qt.formatDateTime(clock.date, "ddd d MMM  HH:mm")
                            color: "#e7ecf3"
                            font.pixelSize: 11
                        }

                        MouseArea {
                            id: controlMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                powerPopup.visible = false
                                controlPopup.visible = !controlPopup.visible
                            }
                        }
                    }

                    Rectangle {
                        id: powerButton
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 27
                        radius: 9
                        color: powerMouse.containsMouse || powerPopup.visible ? "#322027" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "⏻"
                            color: "#b9c2ce"
                            font.pixelSize: 14
                        }

                        MouseArea {
                            id: powerMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                controlPopup.visible = false
                                powerPopup.visible = !powerPopup.visible
                            }
                        }
                    }
                }
            }

            PopupWindow {
                id: controlPopup
                anchor.item: controlButton
                anchor.edges: Edges.Bottom | Edges.Right
                anchor.gravity: Edges.Bottom | Edges.Left
                anchor.margins.top: 8
                implicitWidth: 410
                implicitHeight: 520
                color: "transparent"
                visible: false

                ControlCenterContent {
                    anchors.fill: parent
                    systemState: root.systemState
                }
            }

            PopupWindow {
                id: powerPopup
                anchor.item: powerButton
                anchor.edges: Edges.Bottom | Edges.Right
                anchor.gravity: Edges.Bottom | Edges.Left
                anchor.margins.top: 8
                implicitWidth: 320
                implicitHeight: 230
                color: "transparent"
                visible: false

                PowerMenuContent {
                    anchors.fill: parent
                }
            }
        }
    }
}
