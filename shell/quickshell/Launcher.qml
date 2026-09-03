import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

FloatingWindow {
    id: launcher

    required property var projectState
    signal projectCenterRequested()

    property int selectedIndex: 0
    property var actions: [
        { name: "Terminal", hint: "Open foot", command: ["foot"] },
        { name: "Files", hint: "Open Nautilus", command: ["nautilus"] },
        { name: "Project Center", hint: "Open sn0w project workspace", special: "projects" }
    ]
    property var sshHosts: ["m0ther", "s0n"]

    title: "sn0w Launcher"
    implicitWidth: 720
    implicitHeight: 520

    function mode(): string {
        const text = query.text.trim().toLowerCase();
        if (text.indexOf(">") === 0) return "actions";
        if (text.indexOf("ssh ") === 0) return "ssh";
        if (text.indexOf("project ") === 0) return "projects";
        return "apps";
    }

    function needle(): string {
        let text = query.text.trim().toLowerCase();
        if (mode() === "actions") return text.slice(1).trim();
        if (mode() === "ssh") return text.slice(4).trim();
        if (mode() === "projects") return text.slice(8).trim();
        return text;
    }

    function fuzzy(value: string): bool {
        const n = needle();
        if (n.length === 0) return true;
        const hay = (value || "").toLowerCase();
        let at = 0;
        for (let i = 0; i < hay.length && at < n.length; ++i)
            if (hay[i] === n[at]) ++at;
        return at === n.length;
    }

    function appMatches(entry): bool {
        return fuzzy((entry.name || "") + " " + (entry.genericName || "") + " " + (entry.comment || ""));
    }

    function nextVisible(delta: int): void {
        const repeater = mode() === "apps" ? appRepeater
                       : mode() === "actions" ? actionRepeater
                       : mode() === "ssh" ? sshRepeater
                       : projectRepeater;
        if (!repeater || repeater.count <= 0) return;
        let i = selectedIndex;
        for (let tries = 0; tries < repeater.count; ++tries) {
            i = (i + delta + repeater.count) % repeater.count;
            const item = repeater.itemAt(i);
            if (item && item.visible) {
                selectedIndex = i;
                return;
            }
        }
    }

    function activateSelected(): void {
        const repeater = mode() === "apps" ? appRepeater
                       : mode() === "actions" ? actionRepeater
                       : mode() === "ssh" ? sshRepeater
                       : projectRepeater;
        const item = repeater ? repeater.itemAt(selectedIndex) : null;
        if (item && item.visible && item.activate)
            item.activate();
    }

    function reset(): void {
        selectedIndex = 0;
        query.clear();
        query.forceActiveFocus();
    }

    onVisibleChanged: if (visible) reset()

    Process { id: actionProc }

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
                    Text { text: "sn0w"; color: "#f4f7fb"; font.pixelSize: 22; font.bold: true }
                    Text { text: "Launcher · apps / actions / projects / ssh"; color: "#697586"; font.pixelSize: 11 }
                }
                Item { Layout.fillWidth: true }
                Text { text: "⌘ Space"; color: "#8f9aaa"; font.pixelSize: 10 }
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
                    placeholderText: "Search apps · > actions · project name · ssh host"
                    color: "#f4f7fb"
                    font.pixelSize: 16
                    focus: launcher.visible
                    selectByMouse: true
                    background: Item {}

                    onTextChanged: launcher.selectedIndex = 0

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Down) { launcher.nextVisible(1); event.accepted = true; }
                        else if (event.key === Qt.Key_Up) { launcher.nextVisible(-1); event.accepted = true; }
                        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { launcher.activateSelected(); event.accepted = true; }
                        else if (event.key === Qt.Key_Escape) { launcher.visible = false; query.clear(); event.accepted = true; }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: launcher.mode() === "apps" ? "Applications"
                        : launcher.mode() === "actions" ? "Actions"
                        : launcher.mode() === "ssh" ? "SSH"
                        : "Projects"
                    color: "#9aa5b4"
                    font.pixelSize: 11
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
                Text { text: "↑↓ select · Enter run · Esc close"; color: "#596474"; font.pixelSize: 10 }
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
                    contentHeight: resultsColumn.implicitHeight
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: resultsColumn
                        width: parent.width
                        spacing: 4

                        Repeater {
                            id: appRepeater
                            model: DesktopEntries.applications
                            delegate: Rectangle {
                                id: appItem
                                required property var modelData
                                required property int index
                                property bool match: launcher.mode() === "apps" && launcher.appMatches(modelData)
                                visible: match
                                height: match ? 54 : 0
                                width: resultsColumn.width
                                radius: 10
                                color: index === launcher.selectedIndex ? "#27313d" : (appMouse.containsMouse ? "#1b222c" : "transparent")

                                function activate(): void {
                                    modelData.execute();
                                    launcher.visible = false;
                                    query.clear();
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 12

                                    Image {
                                        source: modelData.icon.length > 0 ? Quickshell.iconPath(modelData.icon) : ""
                                        sourceSize.width: 28
                                        sourceSize.height: 28
                                        Layout.preferredWidth: 30
                                        Layout.preferredHeight: 30
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1
                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.name
                                            color: "#f4f7fb"
                                            font.pixelSize: 14
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.genericName.length > 0 ? modelData.genericName : modelData.comment
                                            color: "#697586"
                                            font.pixelSize: 11
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
                                height: match ? 54 : 0
                                width: resultsColumn.width
                                radius: 10
                                color: index === launcher.selectedIndex ? "#27313d" : (actionMouse.containsMouse ? "#1b222c" : "transparent")

                                function activate(): void {
                                    if (modelData.special === "projects")
                                        launcher.projectCenterRequested();
                                    else {
                                        actionProc.command = modelData.command;
                                        actionProc.running = true;
                                    }
                                    launcher.visible = false;
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12

                                    Text {
                                        text: "›"
                                        color: "#9aa5b4"
                                        font.pixelSize: 17
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Text {
                                            text: modelData.name
                                            color: "#f4f7fb"
                                            font.pixelSize: 14
                                        }
                                        Text {
                                            text: modelData.hint
                                            color: "#697586"
                                            font.pixelSize: 10
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
                            model: launcher.sshHosts
                            delegate: Rectangle {
                                id: sshItem
                                required property string modelData
                                required property int index
                                property bool match: launcher.mode() === "ssh" && launcher.fuzzy(modelData)
                                visible: match
                                height: match ? 54 : 0
                                width: resultsColumn.width
                                radius: 10
                                color: index === launcher.selectedIndex ? "#27313d" : (sshMouse.containsMouse ? "#1b222c" : "transparent")

                                function activate(): void {
                                    actionProc.command = ["foot", "-e", "ssh", modelData];
                                    actionProc.running = true;
                                    launcher.visible = false;
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    Text { text: "⌁"; color: "#9aa5b4" }
                                    Text { text: modelData; color: "#f4f7fb"; font.pixelSize: 14 }
                                    Item { Layout.fillWidth: true }
                                    Text { text: "ssh"; color: "#596474"; font.pixelSize: 10 }
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
                                height: match ? 58 : 0
                                width: resultsColumn.width
                                radius: 10
                                color: index === launcher.selectedIndex ? "#27313d" : (projectMouse.containsMouse ? "#1b222c" : "transparent")

                                function activate(): void {
                                    launcher.projectState.openCode(modelData.path);
                                    launcher.visible = false;
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    Text { text: "◆"; color: "#9aa5b4"; font.pixelSize: 12 }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Text {
                                            text: modelData.name
                                            color: "#f4f7fb"
                                            font.pixelSize: 14
                                        }
                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.path
                                            color: "#697586"
                                            font.pixelSize: 10
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
