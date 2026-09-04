import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

FloatingWindow {
    id: window

    required property var settingsState

    property bool appPickerVisible: false
    property string appTarget: ""
    property string appSearch: ""

    title: "sn0w Settings"
    implicitWidth: 700
    implicitHeight: 560

    function currentApp(value: string) {
        return DesktopEntries.heuristicLookup(value)
    }

    function currentAppName(value: string): string {
        const entry = currentApp(value)
        return entry ? entry.name : value
    }

    function currentAppIcon(value: string): string {
        const entry = currentApp(value)
        if (!entry || !entry.icon || entry.icon.length === 0)
            return ""
        return Quickshell.iconPath(entry.icon)
    }

    function chooseApplication(entry): void {
        if (!entry)
            return

        const command = entry.command && entry.command.length > 0 ? entry.command[0] : entry.id

        if (appTarget === "terminal")
            settingsState.terminal = command
        else if (appTarget === "files")
            settingsState.fileManager = command
        else if (appTarget === "editor")
            settingsState.editor = command

        settingsState.save()
        appPickerVisible = false
        appSearch = ""
    }

    function appMatches(entry): bool {
        const needle = appSearch.trim().toLowerCase()
        if (needle.length === 0)
            return true
        const haystack = ((entry.name || "") + " " + (entry.genericName || "") + " " + (entry.comment || "")).toLowerCase()
        return haystack.indexOf(needle) >= 0
    }

    function urlToPath(url): string {
        let value = url.toString()
        if (value.indexOf("file://") === 0)
            value = value.slice(7)
        return decodeURIComponent(value)
    }

    FolderDialog {
        id: screenshotsDialog
        title: "Choose screenshots folder"

        onAccepted: {
            settingsState.screenshotsDir = window.urlToPath(selectedFolder)
            settingsState.save()
        }
    }

    FolderDialog {
        id: recordingsDialog
        title: "Choose recordings folder"

        onAccepted: {
            settingsState.recordingsDir = window.urlToPath(selectedFolder)
            settingsState.save()
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 20
        color: "#11151b"
        border.width: 1
        border.color: "#2b3440"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 1

                    Text {
                        text: "Settings"
                        color: "#f4f7fb"
                        font.pixelSize: 21
                        font.bold: true
                    }

                    Text {
                        text: "~/.config/sn0w/settings.json"
                        color: "#697586"
                        font.pixelSize: 10
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: settingsState.status
                    color: settingsState.status === "Save failed" ? "#d98c8c" : "#7f8b99"
                    font.pixelSize: 10
                }

                Rectangle {
                    Layout.preferredWidth: 74
                    Layout.preferredHeight: 30
                    radius: 8
                    color: saveMouse.containsMouse ? "#334150" : "#27313d"

                    Text {
                        anchors.centerIn: parent
                        text: settingsState.saving ? "Saving…" : "Save"
                        color: "#f4f7fb"
                        font.pixelSize: 11
                        font.bold: true
                    }

                    MouseArea {
                        id: saveMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: settingsState.save()
                    }
                }
            }

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: width
                contentHeight: settingsColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: settingsColumn
                    width: parent.width
                    spacing: 12

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: projectColumn.implicitHeight + 28
                        radius: 12
                        color: "#171c23"
                        border.width: 1
                        border.color: "#242c36"

                        ColumnLayout {
                            id: projectColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 14
                            spacing: 8

                            Text {
                                text: "Project folders"
                                color: "#f4f7fb"
                                font.pixelSize: 13
                                font.bold: true
                            }

                            Repeater {
                                model: settingsState.projectRoots

                                delegate: RowLayout {
                                    required property string modelData
                                    required property int index
                                    Layout.fillWidth: true
                                    spacing: 8

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData
                                        color: "#cbd3dd"
                                        font.pixelSize: 11
                                        elide: Text.ElideMiddle
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 62
                                        Layout.preferredHeight: 26
                                        radius: 7
                                        color: rootRemoveMouse.containsMouse ? "#342128" : "#20262e"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "Remove"
                                            color: "#aeb8c5"
                                            font.pixelSize: 9
                                        }

                                        MouseArea {
                                            id: rootRemoveMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor

                                            onClicked: {
                                                settingsState.removeProjectRoot(index)
                                                settingsState.save()
                                            }
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                TextField {
                                    id: projectRootField
                                    Layout.fillWidth: true
                                    placeholderText: "~/Code or /mnt/projects"
                                    color: "#f4f7fb"
                                    font.pixelSize: 11

                                    background: Rectangle {
                                        radius: 8
                                        color: "#0d1116"
                                        border.width: 1
                                        border.color: "#28313c"
                                    }
                                }

                                Button {
                                    text: "+ Add"

                                    onClicked: {
                                        settingsState.addProjectRoot(projectRootField.text)
                                        projectRootField.clear()
                                        settingsState.save()
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: sshColumn.implicitHeight + 28
                        radius: 12
                        color: "#171c23"
                        border.width: 1
                        border.color: "#242c36"

                        ColumnLayout {
                            id: sshColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 14
                            spacing: 8

                            Text {
                                text: "SSH hosts"
                                color: "#f4f7fb"
                                font.pixelSize: 13
                                font.bold: true
                            }

                            Repeater {
                                model: settingsState.sshHosts

                                delegate: RowLayout {
                                    required property string modelData
                                    required property int index
                                    Layout.fillWidth: true
                                    spacing: 8

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData
                                        color: "#cbd3dd"
                                        font.pixelSize: 11
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 62
                                        Layout.preferredHeight: 26
                                        radius: 7
                                        color: hostRemoveMouse.containsMouse ? "#342128" : "#20262e"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "Remove"
                                            color: "#aeb8c5"
                                            font.pixelSize: 9
                                        }

                                        MouseArea {
                                            id: hostRemoveMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor

                                            onClicked: {
                                                settingsState.removeSshHost(index)
                                                settingsState.save()
                                            }
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                TextField {
                                    id: sshHostField
                                    Layout.fillWidth: true
                                    placeholderText: "hostname or SSH config alias"
                                    color: "#f4f7fb"
                                    font.pixelSize: 11

                                    background: Rectangle {
                                        radius: 8
                                        color: "#0d1116"
                                        border.width: 1
                                        border.color: "#28313c"
                                    }
                                }

                                Button {
                                    text: "+ Add"

                                    onClicked: {
                                        settingsState.addSshHost(sshHostField.text)
                                        sshHostField.clear()
                                        settingsState.save()
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: appDefaultsColumn.implicitHeight + 28
                        radius: 12
                        color: "#171c23"
                        border.width: 1
                        border.color: "#242c36"

                        ColumnLayout {
                            id: appDefaultsColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 14
                            spacing: 10

                            Text {
                                text: "Default applications"
                                color: "#f4f7fb"
                                font.pixelSize: 13
                                font.bold: true
                            }

                            Repeater {
                                model: [
                                    { label: "Terminal", key: "terminal", value: settingsState.terminal },
                                    { label: "File manager", key: "files", value: settingsState.fileManager },
                                    { label: "Editor", key: "editor", value: settingsState.editor }
                                ]

                                delegate: RowLayout {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    spacing: 10

                                    Text {
                                        Layout.preferredWidth: 96
                                        text: modelData.label
                                        color: "#8f9aaa"
                                        font.pixelSize: 10
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 38
                                        radius: 9
                                        color: "#0d1116"
                                        border.width: 1
                                        border.color: "#28313c"

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 10
                                            anchors.rightMargin: 10
                                            spacing: 9

                                            Image {
                                                source: window.currentAppIcon(modelData.value)
                                                sourceSize.width: 22
                                                sourceSize.height: 22
                                                Layout.preferredWidth: 24
                                                Layout.preferredHeight: 24
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: window.currentAppName(modelData.value)
                                                color: "#f4f7fb"
                                                font.pixelSize: 11
                                                elide: Text.ElideRight
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 74
                                        Layout.preferredHeight: 30
                                        radius: 8
                                        color: browseAppMouse.containsMouse ? "#2a3440" : "#20262e"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "Browse…"
                                            color: "#cbd3dd"
                                            font.pixelSize: 10
                                        }

                                        MouseArea {
                                            id: browseAppMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor

                                            onClicked: {
                                                window.appTarget = modelData.key
                                                window.appSearch = ""
                                                window.appPickerVisible = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: captureColumn.implicitHeight + 28
                        radius: 12
                        color: "#171c23"
                        border.width: 1
                        border.color: "#242c36"

                        ColumnLayout {
                            id: captureColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 14
                            spacing: 10

                            Text {
                                text: "Capture folders"
                                color: "#f4f7fb"
                                font.pixelSize: 13
                                font.bold: true
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Text {
                                    Layout.preferredWidth: 96
                                    text: "Screenshots"
                                    color: "#8f9aaa"
                                    font.pixelSize: 10
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: settingsState.screenshotsDir
                                    color: "#cbd3dd"
                                    font.pixelSize: 11
                                    elide: Text.ElideMiddle
                                }

                                Button {
                                    text: "Browse…"
                                    onClicked: screenshotsDialog.open()
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Text {
                                    Layout.preferredWidth: 96
                                    text: "Recordings"
                                    color: "#8f9aaa"
                                    font.pixelSize: 10
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: settingsState.recordingsDir
                                    color: "#cbd3dd"
                                    font.pixelSize: 11
                                    elide: Text.ElideMiddle
                                }

                                Button {
                                    text: "Browse…"
                                    onClicked: recordingsDialog.open()
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            visible: window.appPickerVisible
            z: 100
            radius: 20
            color: "#11151b"
            border.width: 1
            border.color: "#394452"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Choose application"
                        color: "#f4f7fb"
                        font.pixelSize: 18
                        font.bold: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Button {
                        text: "Cancel"

                        onClicked: {
                            window.appPickerVisible = false
                            window.appSearch = ""
                        }
                    }
                }

                TextField {
                    Layout.fillWidth: true
                    placeholderText: "Search installed applications…"
                    color: "#f4f7fb"
                    text: window.appSearch
                    onTextChanged: window.appSearch = text
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
                        contentHeight: appPickerColumn.implicitHeight
                        boundsBehavior: Flickable.StopAtBounds

                        Column {
                            id: appPickerColumn
                            width: parent.width
                            spacing: 3

                            Repeater {
                                model: DesktopEntries.applications

                                delegate: Rectangle {
                                    id: appChoice
                                    required property var modelData
                                    property bool match: window.appMatches(modelData)
                                    visible: match
                                    height: match ? 48 : 0
                                    width: appPickerColumn.width
                                    radius: 9
                                    color: appChoiceMouse.containsMouse ? "#1b222c" : "transparent"

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10
                                        spacing: 10

                                        Image {
                                            source: modelData.icon.length > 0 ? Quickshell.iconPath(modelData.icon) : ""
                                            sourceSize.width: 26
                                            sourceSize.height: 26
                                            Layout.preferredWidth: 28
                                            Layout.preferredHeight: 28
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 0

                                            Text {
                                                Layout.fillWidth: true
                                                text: modelData.name
                                                color: "#f4f7fb"
                                                font.pixelSize: 12
                                                elide: Text.ElideRight
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: modelData.genericName.length > 0 ? modelData.genericName : modelData.comment
                                                color: "#697586"
                                                font.pixelSize: 9
                                                elide: Text.ElideRight
                                            }
                                        }
                                    }

                                    MouseArea {
                                        id: appChoiceMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: window.chooseApplication(modelData)
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
