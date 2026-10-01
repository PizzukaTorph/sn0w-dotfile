import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: picker

    property bool active: false
    property string mode: "file"
    property string title: mode === "folder" ? "Choose folder" : "Choose file"
    property string currentPath: "~"
    property string selectedPath: ""
    property var entries: []
    property string status: ""

    signal accepted(string path)
    signal cancelled()

    anchors.fill: parent
    visible: active
    z: 200

    function open(startPath: string, selectMode: string, dialogTitle: string): void {
        mode = selectMode
        title = dialogTitle
        currentPath = startPath && startPath.length > 0 ? startPath : "~"
        selectedPath = ""
        active = true
        refresh()
    }

    function close(): void {
        active = false
        selectedPath = ""
    }

    function refresh(): void {
        status = "Loading…"
        listProc.command = [
            "python3",
            "-c",
            "import json,os,sys; p=os.path.abspath(os.path.expanduser(sys.argv[1])); out=[];\ntry:\n  names=sorted(os.listdir(p), key=lambda n: (not os.path.isdir(os.path.join(p,n)), n.lower()))\n  for n in names:\n    q=os.path.join(p,n); out.append({'name':n,'path':q,'dir':os.path.isdir(q),'hidden':n.startswith('.')})\n  print(json.dumps({'path':p,'entries':out}))\nexcept Exception as e:\n  print(json.dumps({'path':p,'entries':[],'error':str(e)}))",
            currentPath
        ]
        if (listProc.running)
            listProc.running = false
        listProc.running = true
    }

    function enter(path: string): void {
        currentPath = path
        selectedPath = ""
        refresh()
    }

    function goUp(): void {
        listProc.command = [
            "python3",
            "-c",
            "import os,sys; p=os.path.abspath(os.path.expanduser(sys.argv[1])); print(os.path.dirname(p) or '/')",
            currentPath
        ]
        listProcMode = "up"
        if (listProc.running)
            listProc.running = false
        listProc.running = true
    }

    property string listProcMode: "list"

    Process {
        id: listProc

        stdout: StdioCollector {
            onStreamFinished: {
                if (picker.listProcMode === "up") {
                    picker.listProcMode = "list"
                    picker.currentPath = text.trim()
                    picker.refresh()
                    return
                }

                try {
                    const data = JSON.parse(text)
                    picker.currentPath = data.path || picker.currentPath
                    picker.entries = data.entries || []
                    picker.status = data.error || ""
                } catch (e) {
                    picker.entries = []
                    picker.status = "Unable to read folder"
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 20
        color: "#0b0e12"
        border.width: 1
        border.color: "#394452"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 10

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        text: picker.title
                        color: "#f4f7fb"
                        font.pixelSize: 18
                        font.bold: true
                    }

                    Text {
                        Layout.fillWidth: true
                        text: picker.currentPath
                        color: "#7f8b99"
                        font.pixelSize: 10
                        elide: Text.ElideMiddle
                    }
                }

                Button {
                    text: "Home"
                    onClicked: picker.enter("~")
                }

                Button {
                    text: "Up"
                    onClicked: picker.goUp()
                }

                Button {
                    text: "Cancel"
                    onClicked: {
                        picker.cancelled()
                        picker.close()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 11
                color: "#11151b"
                border.width: 1
                border.color: "#242c36"
                clip: true

                ListView {
                    id: fileList
                    anchors.fill: parent
                    anchors.margins: 6
                    model: picker.entries
                    spacing: 2
                    clip: true

                    delegate: Rectangle {
                        id: row
                        required property var modelData
                        width: fileList.width
                        height: 42
                        radius: 8
                        color: picker.selectedPath === modelData.path ? "#253342" : (rowMouse.containsMouse ? "#1a212a" : "transparent")

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            Text {
                                text: modelData.dir ? "▸" : "•"
                                color: modelData.dir ? "#8fb9d8" : "#657181"
                                font.pixelSize: 13
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.name
                                color: modelData.hidden ? "#8a94a2" : "#dce3eb"
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }

                            Text {
                                text: modelData.dir ? "folder" : "file"
                                color: "#596474"
                                font.pixelSize: 9
                            }
                        }

                        MouseArea {
                            id: rowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                picker.selectedPath = modelData.path
                            }

                            onDoubleClicked: {
                                if (modelData.dir)
                                    picker.enter(modelData.path)
                                else if (picker.mode === "file") {
                                    picker.accepted(modelData.path)
                                    picker.close()
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: picker.status
                    color: "#d98c8c"
                    font.pixelSize: 9
                }

                Text {
                    visible: picker.selectedPath.length > 0
                    Layout.maximumWidth: 320
                    text: picker.selectedPath
                    color: "#7f8b99"
                    font.pixelSize: 9
                    elide: Text.ElideMiddle
                }

                Button {
                    text: picker.mode === "folder" ? "Use folder" : "Open"
                    enabled: picker.mode === "folder" || picker.selectedPath.length > 0

                    onClicked: {
                        let value = picker.selectedPath
                        if (picker.mode === "folder") {
                            if (value.length > 0) {
                                for (let i = 0; i < picker.entries.length; ++i) {
                                    if (picker.entries[i].path === value && picker.entries[i].dir) {
                                        picker.enter(value)
                                        return
                                    }
                                }
                            }
                            value = picker.currentPath
                        }

                        if (value.length === 0)
                            return

                        picker.accepted(value)
                        picker.close()
                    }
                }
            }
        }
    }
}
