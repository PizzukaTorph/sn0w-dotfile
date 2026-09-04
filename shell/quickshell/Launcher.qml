import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

FloatingWindow {
    id: launcher

    required property var projectState
    required property var settingsState
    signal projectCenterRequested()
    signal settingsRequested()

    property int selectedIndex: 0
    property var actions: [
        { name: "Terminal", hint: "Open " + settingsState.terminal, command: [settingsState.terminal] },
        { name: "Files", hint: "Open " + settingsState.fileManager, command: [settingsState.fileManager] },
        { name: "Project Center", hint: "Open sn0w project workspace", special: "projects" },
        { name: "Settings", hint: "Configure sn0w", special: "settings" }
    ]

    title: "sn0w Launcher"
    implicitWidth: 620
    implicitHeight: 410

    function mode(): string {
        const text = query.text.trim().toLowerCase()
        if (text.indexOf(">") === 0) return "actions"
        if (text.indexOf("ssh ") === 0) return "ssh"
        if (text.indexOf("project ") === 0) return "projects"
        return "apps"
    }

    function setMode(value: string): void {
        selectedIndex = 0
        if (value === "actions") query.text = "> "
        else if (value === "ssh") query.text = "ssh "
        else if (value === "projects") query.text = "project "
        else query.clear()
        query.forceActiveFocus()
    }

    function needle(): string {
        let text = query.text.trim().toLowerCase()
        if (mode() === "actions") return text.slice(1).trim()
        if (mode() === "ssh") return text.slice(4).trim()
        if (mode() === "projects") return text.slice(8).trim()
        return text
    }

    function fuzzy(value: string): bool {
        const n = needle()
        if (n.length === 0) return true
        const hay = (value || "").toLowerCase()
        let at = 0
        for (let i = 0; i < hay.length && at < n.length; ++i) {
            if (hay[i] === n[at]) ++at
        }
        return at === n.length
    }

    function appMatches(entry): bool {
        return fuzzy((entry.name || "") + " " + (entry.genericName || "") + " " + (entry.comment || ""))
    }

    function currentRepeater() {
        if (mode() === "actions") return actionRepeater
        if (mode() === "ssh") return sshRepeater
        if (mode() === "projects") return projectRepeater
        return appRepeater
    }

    function nextVisible(delta: int): void {
        const repeater = currentRepeater()
        if (!repeater || repeater.count <= 0) return
        let i = selectedIndex
        for (let tries = 0; tries < repeater.count; ++tries) {
            i = (i + delta + repeater.count) % repeater.count
            const item = repeater.itemAt(i)
            if (item && item.visible) {
                selectedIndex = i
                return
            }
        }
    }

    function activateSelected(): void {
        const repeater = currentRepeater()
        const item = repeater ? repeater.itemAt(selectedIndex) : null
        if (item && item.visible && item.activate) item.activate()
    }

    function reset(): void {
        selectedIndex = 0
        query.clear()
        projectState.refresh()
        query.forceActiveFocus()
    }

    onVisibleChanged: {
        if (visible) reset()
    }

    Process {
        id: actionProc
    }

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: "#11151b"
        border.width: 1
        border.color: "#2b3440"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "sn0w"
                    color: "#f4f7fb"
                    font.pixelSize: 18
                    font.bold: true
                }

                Text {
                    text: "Launcher"
                    color: "#697586"
                    font.pixelSize: 11
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "⌘ Space"
                    color: "#8f9aaa"
                    font.pixelSize: 10
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                radius: 11
                color: "#0c1015"
                border.width: 1
                border.color: query.activeFocus ? "#3a4655" : "#202630"

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    text: "⌕"
                    color: "#697586"
                    font.pixelSize: 18
                }

                TextField {
                    id: query
                    anchors.fill: parent
                    anchors.leftMargin: 40
                    anchors.rightMargin: 10
                    placeholderText: "Search…"
                    color: "#f4f7fb"
                    font.pixelSize: 15
                    focus: launcher.visible
                    selectByMouse: true
                    background: Item {}

                    onTextChanged: launcher.selectedIndex = 0

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Down) {
                            launcher.nextVisible(1)
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up) {
                            launcher.nextVisible(-1)
                            event.accepted = true
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            launcher.activateSelected()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Escape) {
                            launcher.visible = false
                            query.clear()
                            event.accepted = true
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: [
                        { label: "Apps", mode: "apps" },
                        { label: "Actions", mode: "actions" },
                        { label: "Projects", mode: "projects" },
                        { label: "SSH", mode: "ssh" }
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        Layout.preferredWidth: 72
                        Layout.preferredHeight: 27
                        radius: 8
                        color: launcher.mode() === modelData.mode ? "#293440" : (modeMouse.containsMouse ? "#1c232c" : "#151a20")
                        border.width: 1
                        border.color: launcher.mode() === modelData.mode ? "#46576a" : "#242c36"

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            color: launcher.mode() === modelData.mode ? "#f4f7fb" : "#8b96a5"
                            font.pixelSize: 10
                        }

                        MouseArea {
                            id: modeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: launcher.setMode(modelData.mode)
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "↑↓ · Enter · Esc"
                    color: "#596474"
                    font.pixelSize: 9
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 11
                color: "#0b0d10"
                clip: true

                Flickable {
                    anchors.fill: parent
                    anchors.margins: 6
                    contentWidth: width
                    contentHeight: resultsColumn.implicitHeight
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: resultsColumn
                        width: parent.width
                        spacing: 3

                        Repeater {
                            id: appRepeater
                            model: DesktopEntries.applications

                            delegate: Rectangle {
                                id: appItem
                                required property var modelData
                                required property int index
                                property bool match: launcher.mode() === "apps" && launcher.appMatches(modelData)
                                visible: match
                                height: match ? 46 : 0
                                width: resultsColumn.width
                                radius: 9
                                color: index === launcher.selectedIndex ? "#27313d" : (appMouse.containsMouse ? "#1b222c" : "transparent")

                                function activate(): void {
                                    modelData.execute()
                                    launcher.visible = false
                                    query.clear()
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 9
                                    anchors.rightMargin: 9
                                    spacing: 10

                                    Image {
                                        source: modelData.icon.length > 0 ? Quickshell.iconPath(modelData.icon) : ""
                                        sourceSize.width: 24
                                        sourceSize.height: 24
                                        Layout.preferredWidth: 26
                                        Layout.preferredHeight: 26
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 0

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.name
                                            color: "#f4f7fb"
                                            font.pixelSize: 13
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.genericName.length > 0 ? modelData.genericName : modelData.comment
                                            color: "#697586"
                                            font.pixelSize: 10
                                            elide: Text.ElideRight
                                        }
                                    }
                                }

                                MouseArea {
                                    id: appMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: appItem.activate()
                                }
                            }
                        }

                        Repeater {
                            id: actionRepeater
                            model: launcher.actions

                            delegate: Rectangle {
                                id: actionItem
                                required property var modelData
                                required property int index
                                property bool match: launcher.mode() === "actions" && launcher.fuzzy(modelData.name + " " + modelData.hint)
                                visible: match
                                height: match ? 46 : 0
                                width: resultsColumn.width
                                radius: 9
                                color: index === launcher.selectedIndex ? "#27313d" : (actionMouse.containsMouse ? "#1b222c" : "transparent")

                                function activate(): void {
                                    if (modelData.special === "projects") {
                                        launcher.projectCenterRequested()
                                    } else if (modelData.special === "settings") {
                                        launcher.settingsRequested()
                                    } else {
                                        actionProc.command = modelData.command
                                        actionProc.running = true
                                    }
                                    launcher.visible = false
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10

                                    Text {
                                        text: "›"
                                        color: "#9aa5b4"
                                        font.pixelSize: 16
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 0

                                        Text {
                                            text: modelData.name
                                            color: "#f4f7fb"
                                            font.pixelSize: 13
                                        }

                                        Text {
                                            text: modelData.hint
                                            color: "#697586"
                                            font.pixelSize: 9
                                        }
                                    }
                                }

                                MouseArea {
                                    id: actionMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: actionItem.activate()
                                }
                            }
                        }

                        Repeater {
                            id: sshRepeater
                            model: launcher.settingsState.sshHosts

                            delegate: Rectangle {
                                id: sshItem
                                required property var modelData
                                required property int index
                                property string endpointName: modelData && modelData.name ? modelData.name : ""
                                property string endpointHost: modelData && modelData.host ? modelData.host : ""
                                property string endpointUser: modelData && modelData.user ? modelData.user : ""
                                property bool match: launcher.mode() === "ssh" && launcher.fuzzy(endpointName + " " + endpointHost + " " + endpointUser)
                                visible: match
                                height: match ? 46 : 0
                                width: resultsColumn.width
                                radius: 9
                                color: index === launcher.selectedIndex ? "#27313d" : (sshMouse.containsMouse ? "#1b222c" : "transparent")

                                function activate(): void {
                                    if (endpointName.length === 0)
                                        return
                                    actionProc.command = [
                                        "sh",
                                        "-lc",
                                        "exec " + launcher.settingsState.terminal + " -e sn0w-ssh " + JSON.stringify(endpointName)
                                    ]
                                    actionProc.running = true
                                    launcher.visible = false
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10

                                    Text {
                                        text: "⌁"
                                        color: "#9aa5b4"
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 0

                                        Text {
                                            text: sshItem.endpointName
                                            color: "#f4f7fb"
                                            font.pixelSize: 13
                                        }

                                        Text {
                                            text: (sshItem.endpointUser.length > 0 ? sshItem.endpointUser + "@" : "") + sshItem.endpointHost
                                            color: "#697586"
                                            font.pixelSize: 9
                                        }
                                    }

                                    Text {
                                        text: modelData && modelData.auth === "password" ? "password" : "key"
                                        color: "#596474"
                                        font.pixelSize: 9
                                    }
                                }

                                MouseArea {
                                    id: sshMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: sshItem.activate()
                                }
                            }
                        }

                        Repeater {
                            id: projectRepeater
                            model: launcher.projectState.projects

                            delegate: Rectangle {
                                id: projectItem
                                required property var modelData
                                required property int index
                                property bool match: launcher.mode() === "projects" && launcher.fuzzy(modelData.name + " " + modelData.path)
                                visible: match
                                height: match ? 48 : 0
                                width: resultsColumn.width
                                radius: 9
                                color: index === launcher.selectedIndex ? "#27313d" : (projectMouse.containsMouse ? "#1b222c" : "transparent")

                                function activate(): void {
                                    launcher.projectState.openCode(modelData.path)
                                    launcher.visible = false
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10

                                    Text {
                                        text: "◆"
                                        color: "#9aa5b4"
                                        font.pixelSize: 11
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 0

                                        Text {
                                            text: modelData.name
                                            color: "#f4f7fb"
                                            font.pixelSize: 13
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.path
                                            color: "#697586"
                                            font.pixelSize: 9
                                            elide: Text.ElideMiddle
                                        }
                                    }
                                }

                                MouseArea {
                                    id: projectMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: projectItem.activate()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
