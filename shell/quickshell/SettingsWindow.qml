import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

FloatingWindow {
    id: window

    required property var settingsState

    property bool appPickerVisible: false
    property string appTarget: ""
    property string appSearch: ""
    property bool sshEditorVisible: false
    property int sshEditIndex: -1
    property string sshKeySource: ""
    property string pathPickerTarget: ""

    title: "sn0w Settings"
    implicitWidth: 700
    implicitHeight: 560
    color: "transparent"

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

    function openSshEditor(index: int): void {
        sshEditIndex = index
        sshKeySource = ""

        if (index >= 0 && index < settingsState.sshHosts.length) {
            const endpoint = settingsState.sshHosts[index]
            sshNameField.text = endpoint.name || ""
            sshHostField.text = endpoint.host || ""
            sshPortField.text = String(endpoint.port || 22)
            sshUserField.text = endpoint.user || ""
            sshAuth.currentIndex = endpoint.auth === "password" ? 1 : 0
            sshPasswordField.text = ""
        } else {
            sshNameField.text = ""
            sshHostField.text = ""
            sshPortField.text = "22"
            sshUserField.text = ""
            sshAuth.currentIndex = 0
            sshPasswordField.text = ""
        }

        sshEditorVisible = true
    }

    function saveSshEditor(): void {
        const endpoint = {
            name: sshNameField.text.trim(),
            host: sshHostField.text.trim(),
            port: parseInt(sshPortField.text || "22"),
            user: sshUserField.text.trim(),
            auth: sshAuth.currentIndex === 1 ? "password" : "key"
        }

        if (endpoint.auth === "key") {
            if (sshKeySource.length > 0) {
                endpoint.keyMode = "import"
                endpoint.keySource = sshKeySource
            } else {
                endpoint.keyMode = "generate"
            }
        }

        if (endpoint.name.length === 0 || endpoint.host.length === 0 || endpoint.user.length === 0)
            return

        settingsState.saveSshEndpoint(endpoint, sshPasswordField.text)
        sshEditorVisible = false
    }

    function browseSshKey(): void {
        pathPickerTarget = "ssh-key"
        nativePathPicker.open("~/.ssh", "file", "Import SSH private key")
    }

    function browseScreenshots(): void {
        pathPickerTarget = "screenshots"
        nativePathPicker.open(settingsState.screenshotsDir, "folder", "Choose screenshots folder")
    }

    function browseRecordings(): void {
        pathPickerTarget = "recordings"
        nativePathPicker.open(settingsState.recordingsDir, "folder", "Choose recordings folder")
    }

    Rectangle {
        anchors.fill: parent
        radius: 20
        color: "#11151b"
        border.width: 0

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
                        text: "sn0w owns the plumbing — you choose what you want"
                        color: "#697586"
                        font.pixelSize: 10
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: settingsState.sshBusy ? settingsState.sshStatus : settingsState.status
                    color: settingsState.status === "Save failed" || settingsState.sshStatus === "SSH failed" ? "#d98c8c" : "#7f8b99"
                    font.pixelSize: 10
                }

                Button {
                    text: settingsState.saving ? "Saving…" : "Save"
                    enabled: !settingsState.saving
                    onClicked: settingsState.save()
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

                                    Button {
                                        text: "Remove"
                                        onClicked: settingsState.removeProjectRoot(index)
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
                                }

                                Button {
                                    text: "+ Add"

                                    onClicked: {
                                        settingsState.addProjectRoot(projectRootField.text)
                                        projectRootField.clear()
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

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: "SSH endpoints"
                                    color: "#f4f7fb"
                                    font.pixelSize: 13
                                    font.bold: true
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                Button {
                                    text: "+ Add endpoint"
                                    onClicked: window.openSshEditor(-1)
                                }
                            }

                            Text {
                                text: "Keys, ~/.ssh/config and passwords are managed automatically."
                                color: "#697586"
                                font.pixelSize: 9
                            }

                            Repeater {
                                model: settingsState.sshHosts

                                delegate: Rectangle {
                                    required property var modelData
                                    required property int index
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 52
                                    radius: 9
                                    color: "#0d1116"
                                    border.width: 1
                                    border.color: "#28313c"

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 8
                                        spacing: 9

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 1

                                            Text {
                                                text: modelData.name || "Unnamed"
                                                color: "#f4f7fb"
                                                font.pixelSize: 12
                                                font.bold: true
                                            }

                                            Text {
                                                text: (modelData.user ? modelData.user + "@" : "") + (modelData.host || "") + ":" + (modelData.port || 22)
                                                color: "#697586"
                                                font.pixelSize: 9
                                            }
                                        }

                                        Text {
                                            text: modelData.legacy ? "needs setup" : (modelData.auth === "password" ? "password" : "key")
                                            color: modelData.legacy ? "#d9a56f" : "#7f8b99"
                                            font.pixelSize: 9
                                        }

                                        Button {
                                            text: "Configure"
                                            onClicked: window.openSshEditor(index)
                                        }

                                        Button {
                                            text: "Remove"
                                            onClicked: settingsState.removeSshHost(index)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    InputSettingsCard {
                        settingsState: window.settingsState
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

                                    Button {
                                        text: "Browse…"

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
                                    onClicked: window.browseScreenshots()
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
                                    onClicked: window.browseRecordings()
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
            border.width: 0

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
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: modelData.genericName || modelData.comment
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

        Rectangle {
            anchors.fill: parent
            visible: window.sshEditorVisible
            z: 110
            radius: 20
            color: "#11151b"
            border.width: 0

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 22
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: 1

                        Text {
                            text: window.sshEditIndex >= 0 ? "Configure SSH endpoint" : "Add SSH endpoint"
                            color: "#f4f7fb"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Text {
                            text: "sn0w will configure ~/.ssh and secure credentials for you"
                            color: "#697586"
                            font.pixelSize: 9
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Button {
                        text: "Cancel"
                        onClicked: window.sshEditorVisible = false
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 12
                    rowSpacing: 9

                    Text {
                        text: "Name"
                        color: "#8f9aaa"
                    }

                    TextField {
                        id: sshNameField
                        Layout.fillWidth: true
                        placeholderText: "m0ther"
                    }

                    Text {
                        text: "Host"
                        color: "#8f9aaa"
                    }

                    TextField {
                        id: sshHostField
                        Layout.fillWidth: true
                        placeholderText: "server.example.com or 10.0.0.10"
                    }

                    Text {
                        text: "Port"
                        color: "#8f9aaa"
                    }

                    TextField {
                        id: sshPortField
                        Layout.fillWidth: true
                        text: "22"
                        inputMethodHints: Qt.ImhDigitsOnly
                    }

                    Text {
                        text: "User"
                        color: "#8f9aaa"
                    }

                    TextField {
                        id: sshUserField
                        Layout.fillWidth: true
                        placeholderText: "pizzu"
                    }

                    Text {
                        text: "Authentication"
                        color: "#8f9aaa"
                    }

                    ComboBox {
                        id: sshAuth
                        Layout.fillWidth: true
                        model: ["SSH key", "Password"]
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: sshAuth.currentIndex === 0 ? 100 : 92
                    radius: 10
                    color: "#171c23"
                    border.width: 1
                    border.color: "#28313c"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Text {
                            text: sshAuth.currentIndex === 0 ? "SSH key" : "Password"
                            color: "#f4f7fb"
                            font.pixelSize: 12
                            font.bold: true
                        }

                        RowLayout {
                            visible: sshAuth.currentIndex === 0
                            Layout.fillWidth: true

                            Text {
                                Layout.fillWidth: true
                                text: window.sshKeySource.length > 0 ? window.sshKeySource : "Generate and manage an Ed25519 key automatically"
                                color: "#8f9aaa"
                                font.pixelSize: 9
                                elide: Text.ElideMiddle
                            }

                            Button {
                                text: "Import key…"
                                onClicked: window.browseSshKey()
                            }
                        }

                        TextField {
                            id: sshPasswordField
                            visible: sshAuth.currentIndex === 1
                            Layout.fillWidth: true
                            echoMode: TextInput.Password
                            placeholderText: window.sshEditIndex >= 0 ? "Leave blank to keep saved password" : "Password"
                        }

                        Text {
                            visible: sshAuth.currentIndex === 1
                            text: "Stored in the desktop keyring, never in settings.json"
                            color: "#697586"
                            font.pixelSize: 9
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: "Generated/imported private keys are kept in ~/.ssh/sn0w with safe permissions."
                        color: "#596474"
                        font.pixelSize: 9
                        wrapMode: Text.WordWrap
                    }

                    Button {
                        text: settingsState.sshBusy ? "Saving…" : "Save endpoint"
                        enabled: !settingsState.sshBusy
                        onClicked: window.saveSshEditor()
                    }
                }
            }
        }

        NativePathPicker {
            id: nativePathPicker

            onAccepted: path => {
                if (window.pathPickerTarget === "ssh-key") {
                    window.sshKeySource = path
                    return
                }

                if (window.pathPickerTarget === "screenshots") {
                    settingsState.screenshotsDir = path
                    settingsState.save()
                    return
                }

                if (window.pathPickerTarget === "recordings") {
                    settingsState.recordingsDir = path
                    settingsState.save()
                }
            }
        }
    }
}
