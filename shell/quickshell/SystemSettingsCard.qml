import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    Layout.fillWidth: true
    Layout.preferredHeight: contentColumn.implicitHeight + 28
    radius: 12
    color: "#171c23"
    border.width: 1
    border.color: "#242c36"

    property bool wifiEnabled: false
    property string wifiName: "Disconnected"
    property bool bluetoothEnabled: false
    property int volume: 0
    property bool muted: false
    property string powerProfile: "unknown"
    property real displayScale: 1.0
    property string displayName: "No active display"
    property string displayMode: ""
    property bool busy: false

    function refresh(): void {
        if (statusProc.running)
            return
        statusProc.running = true
    }

    function runAction(args): void {
        if (actionProc.running)
            return
        actionProc.command = ["sn0w-system"].concat(args)
        root.busy = true
        actionProc.running = true
    }

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 14
        spacing: 14

        Text {
            text: "System"
            color: "#f4f7fb"
            font.pixelSize: 13
            font.bold: true
        }

        Text {
            text: "Display, sound, power and connectivity"
            color: "#697586"
            font.pixelSize: 9
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 92
            radius: 10
            color: "#0d1116"
            border.width: 1
            border.color: "#28313c"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 7

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Display"
                        color: "#f4f7fb"
                        font.pixelSize: 11
                        font.bold: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.displayName + (root.displayMode.length > 0 ? " · " + root.displayMode : "")
                        color: "#697586"
                        font.pixelSize: 9
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        Layout.preferredWidth: 84
                        text: "Scale"
                        color: "#8f9aaa"
                        font.pixelSize: 10
                    }

                    Slider {
                        id: scaleSlider
                        Layout.fillWidth: true
                        from: 0.75
                        to: 3.0
                        stepSize: 0.25
                        value: root.displayScale

                        onMoved: {
                            root.displayScale = value
                        }
                    }

                    Text {
                        Layout.preferredWidth: 42
                        horizontalAlignment: Text.AlignRight
                        text: root.displayScale.toFixed(2) + "×"
                        color: "#cbd3dd"
                        font.pixelSize: 10
                    }

                    Button {
                        text: "Apply"
                        enabled: !root.busy
                        onClicked: root.runAction(["display-scale", root.displayScale.toFixed(2)])
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 92
            radius: 10
            color: "#0d1116"
            border.width: 1
            border.color: "#28313c"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 7

                Text {
                    text: "Sound"
                    color: "#f4f7fb"
                    font.pixelSize: 11
                    font.bold: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        Layout.preferredWidth: 84
                        text: "Output"
                        color: "#8f9aaa"
                        font.pixelSize: 10
                    }

                    Slider {
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        stepSize: 1
                        value: root.volume

                        onMoved: {
                            root.volume = Math.round(value)
                            volumeDebounce.restart()
                        }
                    }

                    Text {
                        Layout.preferredWidth: 38
                        horizontalAlignment: Text.AlignRight
                        text: root.volume + "%"
                        color: "#cbd3dd"
                        font.pixelSize: 10
                    }

                    Button {
                        text: root.muted ? "Unmute" : "Mute"
                        enabled: !root.busy
                        onClicked: root.runAction(["mute-toggle"])
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 92
            radius: 10
            color: "#0d1116"
            border.width: 1
            border.color: "#28313c"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 7

                Text {
                    text: "Power"
                    color: "#f4f7fb"
                    font.pixelSize: 11
                    font.bold: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        Layout.preferredWidth: 84
                        text: "Profile"
                        color: "#8f9aaa"
                        font.pixelSize: 10
                    }

                    ComboBox {
                        id: powerCombo
                        Layout.fillWidth: true
                        model: ["power-saver", "balanced", "performance"]

                        Component.onCompleted: syncPowerIndex()

                        function syncPowerIndex(): void {
                            const index = model.indexOf(root.powerProfile)
                            if (index >= 0)
                                currentIndex = index
                        }

                        onActivated: root.runAction(["power-profile", currentText])
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 116
            radius: 10
            color: "#0d1116"
            border.width: 1
            border.color: "#28313c"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 7

                Text {
                    text: "Network & Bluetooth"
                    color: "#f4f7fb"
                    font.pixelSize: 11
                    font.bold: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        Layout.preferredWidth: 84
                        text: "Wi-Fi"
                        color: "#8f9aaa"
                        font.pixelSize: 10
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.wifiEnabled ? root.wifiName : "Off"
                        color: "#cbd3dd"
                        font.pixelSize: 10
                        elide: Text.ElideRight
                    }

                    Switch {
                        checked: root.wifiEnabled
                        onToggled: root.runAction(["wifi", checked ? "on" : "off"])
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        Layout.preferredWidth: 84
                        text: "Bluetooth"
                        color: "#8f9aaa"
                        font.pixelSize: 10
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.bluetoothEnabled ? "On" : "Off"
                        color: "#cbd3dd"
                        font.pixelSize: 10
                    }

                    Switch {
                        checked: root.bluetoothEnabled
                        onToggled: root.runAction(["bluetooth", checked ? "on" : "off"])
                    }
                }
            }
        }
    }

    Timer {
        id: volumeDebounce
        interval: 120
        repeat: false
        onTriggered: root.runAction(["volume", String(root.volume)])
    }

    Timer {
        interval: 5000
        repeat: true
        running: true
        onTriggered: root.refresh()
    }

    Process {
        id: statusProc
        command: ["sn0w-system", "status"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text)
                    root.wifiEnabled = data.wifi === true
                    root.wifiName = data.wifiName || "Disconnected"
                    root.bluetoothEnabled = data.bluetooth === true
                    root.volume = data.volume !== undefined ? data.volume : root.volume
                    root.muted = data.muted === true
                    root.powerProfile = data.powerProfile || "unknown"

                    const monitors = data.monitors || []
                    if (monitors.length > 0) {
                        let active = monitors[0]
                        for (let i = 0; i < monitors.length; ++i) {
                            if (monitors[i].focused) {
                                active = monitors[i]
                                break
                            }
                        }
                        root.displayName = active.name || "Display"
                        root.displayMode = String(active.width || 0) + "×" + String(active.height || 0) + " @ " + Number(active.refreshRate || 0).toFixed(0) + "Hz"
                        root.displayScale = active.scale || 1.0
                    }
                    powerCombo.syncPowerIndex()
                } catch (e) {
                }
            }
        }
    }

    Process {
        id: actionProc
        onRunningChanged: {
            if (!running) {
                root.busy = false
                refreshDelay.restart()
            }
        }
    }

    Timer {
        id: refreshDelay
        interval: 350
        repeat: false
        onTriggered: root.refresh()
    }
}
