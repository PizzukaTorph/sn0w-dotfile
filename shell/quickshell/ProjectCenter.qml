import Quickshell
import QtQuick
import QtQuick.Layouts

FloatingWindow {
    id: panel

    required property var projectState

    title: "sn0w Project Center"
    implicitWidth: 960
    implicitHeight: 620
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        radius: 16
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
                    Text { text: "Project Center"; color: "#f4f7fb"; font.pixelSize: 22; font.bold: true }
                    Text { text: projectState.projects.length + " detected Git projects"; color: "#697586"; font.pixelSize: 10 }
                }
                Item { Layout.fillWidth: true }
                ColumnLayout {
                    spacing: 1
                    Text { Layout.alignment: Qt.AlignRight; text: projectState.actionStatus; color: projectState.lastError.length > 0 ? "#d98c8c" : "#8f9aaa"; font.pixelSize: 10 }
                    Text { Layout.alignment: Qt.AlignRight; visible: projectState.lastError.length > 0; text: projectState.lastError; color: "#9d6e76"; font.pixelSize: 8; elide: Text.ElideRight; Layout.preferredWidth: 320 }
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
                        spacing: 8

                        Repeater {
                            model: projectState.projects
                            delegate: Rectangle {
                                id: projectCard
                                required property var modelData
                                property bool sessionRunning: modelData.session && modelData.session.running === true
                                property bool sessionLaunching: modelData.session && modelData.session.launching === true
                                property int windowCount: modelData.session && modelData.session.windowCount ? modelData.session.windowCount : 0
                                property var services: modelData.services || []
                                property var doctor: projectState.doctorResults[modelData.path] || null
                                property int readyServices: {
                                    let count = 0
                                    for (let i = 0; i < services.length; ++i) {
                                        if (services[i].ready === true)
                                            count++
                                    }
                                    return count
                                }
                                property int totalServices: services.length

                                width: projectColumn.width
                                height: 98 + (totalServices > 0 ? 10 + totalServices * 38 : 0)
                                radius: 12
                                color: "#14191f"
                                border.width: 1
                                border.color: sessionRunning ? "#2b3834" : "#242c36"

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 8

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 64
                                        spacing: 10

                                        Rectangle {
                                            Layout.preferredWidth: 40
                                            Layout.preferredHeight: 40
                                            radius: 11
                                            color: projectCard.sessionRunning ? "#26352e" : "#252d38"
                                            Text { anchors.centerIn: parent; text: projectCard.sessionLaunching ? "…" : (projectCard.sessionRunning ? "●" : "◆"); color: projectCard.sessionLaunching ? "#d9a56f" : "#dce3ec"; font.pixelSize: 14; font.bold: true }
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 2

                                            RowLayout {
                                                Rectangle {
                                                    Layout.preferredWidth: projectNameText.implicitWidth + 12
                                                    Layout.preferredHeight: 24
                                                    radius: 7
                                                    color: projectNameMouse.containsMouse ? "#232c36" : "transparent"
                                                    Text {
                                                        id: projectNameText
                                                        anchors.centerIn: parent
                                                        text: projectCard.modelData.name
                                                        color: projectNameMouse.containsMouse ? "#ffffff" : "#f4f7fb"
                                                        font.pixelSize: 14
                                                        font.bold: true
                                                    }
                                                    MouseArea {
                                                        id: projectNameMouse
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: {
                                                            if (projectCard.sessionRunning)
                                                                projectState.resumeProject(projectCard.modelData.path)
                                                            else
                                                                projectState.startProject(projectCard.modelData.path)
                                                            panel.visible = false
                                                        }
                                                    }
                                                }
                                                Text { text: projectCard.modelData.branch ? "  " + projectCard.modelData.branch + (projectCard.modelData.dirty ? " *" : "") : ""; color: "#8f9aaa"; font.pixelSize: 10 }
                                                Rectangle {
                                                    visible: projectCard.doctor !== null
                                                    Layout.preferredWidth: doctorText.implicitWidth + 12
                                                    Layout.preferredHeight: 20
                                                    radius: 6
                                                    color: projectCard.doctor && projectCard.doctor.ok ? "#1d2b24" : "#302127"
                                                    Text { id: doctorText; anchors.centerIn: parent; text: projectCard.doctor && projectCard.doctor.ok ? "ready" : "check failed"; color: projectCard.doctor && projectCard.doctor.ok ? "#8fb69d" : "#d98c8c"; font.pixelSize: 8 }
                                                }
                                            }

                                            Text { Layout.fillWidth: true; text: projectCard.modelData.path; color: "#697586"; font.pixelSize: 9; elide: Text.ElideMiddle }
                                            Text {
                                                text: {
                                                    if (projectCard.sessionLaunching) return "Session launching…"
                                                    if (!projectCard.sessionRunning) return "Session stopped · click project name to open workspace"
                                                    let parts = ["Session running"]
                                                    if (projectCard.windowCount > 0) parts.push(projectCard.windowCount + " windows")
                                                    if (projectCard.totalServices > 0) parts.push(projectCard.readyServices + "/" + projectCard.totalServices + " ready")
                                                    return parts.join(" · ")
                                                }
                                                color: projectCard.sessionLaunching ? "#d9a56f" : (projectCard.sessionRunning ? "#8fb69d" : "#596474")
                                                font.pixelSize: 9
                                            }
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 54; Layout.preferredHeight: 30; radius: 8
                                            color: doctorMouse.containsMouse ? "#29313c" : "#1b222c"
                                            Text { anchors.centerIn: parent; text: "Check"; color: "#cbd3dd"; font.pixelSize: 9 }
                                            MouseArea { id: doctorMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: projectState.doctorProject(projectCard.modelData.path) }
                                        }
                                        Rectangle {
                                            Layout.preferredWidth: 62; Layout.preferredHeight: 30; radius: 8
                                            color: sessionMouse.containsMouse ? "#303946" : "#222a34"
                                            Text { anchors.centerIn: parent; text: projectCard.sessionRunning ? "Resume" : "Start"; color: "#f4f7fb"; font.pixelSize: 10; font.bold: true }
                                            MouseArea {
                                                id: sessionMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                onClicked: projectCard.sessionRunning ? projectState.resumeProject(projectCard.modelData.path) : projectState.startProject(projectCard.modelData.path)
                                            }
                                        }
                                        Rectangle {
                                            Layout.preferredWidth: 48; Layout.preferredHeight: 30; radius: 8; visible: projectCard.sessionRunning
                                            color: stopMouse.containsMouse ? "#3a252a" : "#251d21"
                                            Text { anchors.centerIn: parent; text: "Stop"; color: "#d8b4ba"; font.pixelSize: 10 }
                                            MouseArea { id: stopMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: projectState.stopProject(projectCard.modelData.path) }
                                        }
                                        Repeater {
                                            model: ["Code", "Terminal", "Files"]
                                            delegate: Rectangle {
                                                required property string modelData
                                                Layout.preferredWidth: 58; Layout.preferredHeight: 30; radius: 8
                                                color: actionMouse.containsMouse ? "#29313c" : "#1b222c"
                                                Text { anchors.centerIn: parent; text: modelData; color: "#dce3ec"; font.pixelSize: 9 }
                                                MouseArea {
                                                    id: actionMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        if (modelData === "Code") projectState.openCode(projectCard.modelData.path)
                                                        else if (modelData === "Terminal") projectState.openTerminal(projectCard.modelData.path)
                                                        else projectState.openFiles(projectCard.modelData.path)
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 4
                                        visible: projectCard.totalServices > 0
                                        Repeater {
                                            model: projectCard.services
                                            delegate: Rectangle {
                                                id: serviceRow
                                                required property var modelData
                                                property bool running: (modelData.state || "").toLowerCase() === "running"
                                                property bool healthy: modelData.ready === true
                                                property bool hasPorts: (modelData.ports || []).length > 0
                                                Layout.fillWidth: true; Layout.preferredHeight: 34; radius: 8
                                                color: "#0e1318"; border.width: 1; border.color: serviceRow.healthy ? "#203029" : "#29252a"
                                                RowLayout {
                                                    anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 8; spacing: 8
                                                    Text { text: serviceRow.running ? "●" : "○"; color: serviceRow.healthy ? "#8fb69d" : (serviceRow.running ? "#d9a56f" : "#697586"); font.pixelSize: 9 }
                                                    Text { Layout.preferredWidth: 150; text: serviceRow.modelData.name; color: "#dce3ec"; font.pixelSize: 10; elide: Text.ElideRight }
                                                    Text { Layout.preferredWidth: 95; text: serviceRow.modelData.health || serviceRow.modelData.state || "unknown"; color: serviceRow.healthy ? "#8fb69d" : "#b18a91"; font.pixelSize: 9 }
                                                    Text { Layout.fillWidth: true; text: serviceRow.hasPorts ? serviceRow.modelData.ports.length + " published port" + (serviceRow.modelData.ports.length === 1 ? "" : "s") : ""; color: "#596474"; font.pixelSize: 9 }
                                                    Repeater {
                                                        model: ["Logs", "Exec", "Open", "Restart"]
                                                        delegate: Rectangle {
                                                            required property string modelData
                                                            Layout.preferredWidth: 52; Layout.preferredHeight: 24; radius: 7
                                                            visible: modelData !== "Open" || serviceRow.hasPorts
                                                            color: serviceActionMouse.containsMouse ? "#29313c" : "#192028"
                                                            Text { anchors.centerIn: parent; text: modelData; color: "#cbd3dd"; font.pixelSize: 8 }
                                                            MouseArea {
                                                                id: serviceActionMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                                onClicked: {
                                                                    if (modelData === "Logs") projectState.openServiceLogs(projectCard.modelData.path, serviceRow.modelData.name)
                                                                    else if (modelData === "Exec") projectState.execService(projectCard.modelData.path, serviceRow.modelData.name)
                                                                    else if (modelData === "Open") projectState.openService(projectCard.modelData.path, serviceRow.modelData.name)
                                                                    else projectState.restartService(projectCard.modelData.path, serviceRow.modelData.name)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Text { visible: projectState.projects.length === 0; Layout.alignment: Qt.AlignHCenter; text: "No Git projects detected in configured project folders"; color: "#596474"; font.pixelSize: 10 }
        }
    }
}
