import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    required property var settingsState

    property var keyboardMaps: [
        { label: "Italian — Mac / Apple", layout: "it", variant: "mac" },
        { label: "Italian — PC", layout: "it", variant: "" },
        { label: "English (US) — Mac / Apple", layout: "us", variant: "mac" },
        { label: "English (US) — PC", layout: "us", variant: "" },
        { label: "English (UK) — Mac / Apple", layout: "gb", variant: "mac" },
        { label: "English (UK) — PC", layout: "gb", variant: "" },
        { label: "German — Mac / Apple", layout: "de", variant: "mac" },
        { label: "German — PC", layout: "de", variant: "" },
        { label: "French — Mac / Apple", layout: "fr", variant: "mac" },
        { label: "French — PC", layout: "fr", variant: "" },
        { label: "Spanish — Mac / Apple", layout: "es", variant: "mac" },
        { label: "Spanish — PC", layout: "es", variant: "" }
    ]

    function keyboardMapIndex(): int {
        for (let i = 0; i < keyboardMaps.length; ++i) {
            const map = keyboardMaps[i]
            if (map.layout === settingsState.keyboardLayout && map.variant === settingsState.keyboardVariant)
                return i
        }
        return 0
    }

    Layout.fillWidth: true
    Layout.preferredHeight: content.implicitHeight + 28
    radius: 12
    color: "#171c23"
    border.width: 1
    border.color: "#242c36"

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 14
        spacing: 10

        Text {
            text: "Input / Keyboard & Trackpad"
            color: "#f4f7fb"
            font.pixelSize: 13
            font.bold: true
        }

        Text {
            text: "Mac-like defaults, adjustable live through Hyprland."
            color: "#697586"
            font.pixelSize: 9
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 14
            rowSpacing: 8

            Text {
                text: "Keyboard map"
                color: "#cbd3dd"
                font.pixelSize: 10
            }

            ComboBox {
                Layout.preferredWidth: 250
                model: root.keyboardMaps
                textRole: "label"
                currentIndex: root.keyboardMapIndex()

                onActivated: {
                    const entry = root.keyboardMaps[currentIndex]
                    if (entry)
                        root.settingsState.setKeyboardMap(entry.layout, entry.variant)
                }
            }

            Text {
                text: "Natural scrolling"
                color: "#cbd3dd"
                font.pixelSize: 10
            }

            Switch {
                checked: root.settingsState.naturalScroll
                onToggled: root.settingsState.setNaturalScroll(checked)
            }

            Text {
                text: "Tap to click"
                color: "#cbd3dd"
                font.pixelSize: 10
            }

            Switch {
                checked: root.settingsState.tapToClick
                onToggled: root.settingsState.setTapToClick(checked)
            }

            Text {
                text: "Two-finger secondary click"
                color: "#cbd3dd"
                font.pixelSize: 10
            }

            Switch {
                checked: root.settingsState.twoFingerRightClick
                onToggled: root.settingsState.setTwoFingerRightClick(checked)
            }

            Text {
                text: "Tap and drag"
                color: "#cbd3dd"
                font.pixelSize: 10
            }

            Switch {
                checked: root.settingsState.tapAndDrag
                onToggled: root.settingsState.setTapAndDrag(checked)
            }

            Text {
                text: "Drag lock"
                color: "#cbd3dd"
                font.pixelSize: 10
            }

            ComboBox {
                Layout.preferredWidth: 160
                model: ["Off", "Timed", "Sticky"]
                currentIndex: root.settingsState.dragLock
                onActivated: root.settingsState.setDragLock(currentIndex)
            }

            Text {
                text: "Disable while typing"
                color: "#cbd3dd"
                font.pixelSize: 10
            }

            Switch {
                checked: root.settingsState.disableWhileTyping
                onToggled: root.settingsState.setDisableWhileTyping(checked)
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#242c36"
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                Text { text: "Pointer speed"; color: "#cbd3dd"; font.pixelSize: 10 }
                Item { Layout.fillWidth: true }
                Text { text: root.settingsState.pointerSpeed.toFixed(2); color: "#8f9aaa"; font.pixelSize: 9 }
            }

            Slider {
                Layout.fillWidth: true
                from: -1.0
                to: 1.0
                stepSize: 0.05
                value: root.settingsState.pointerSpeed
                onMoved: root.settingsState.setPointerSpeed(value)
            }

            RowLayout {
                Layout.fillWidth: true
                Text { text: "Touchpad scroll speed"; color: "#cbd3dd"; font.pixelSize: 10 }
                Item { Layout.fillWidth: true }
                Text { text: root.settingsState.touchpadScrollFactor.toFixed(2) + "×"; color: "#8f9aaa"; font.pixelSize: 9 }
            }

            Slider {
                Layout.fillWidth: true
                from: 0.25
                to: 2.0
                stepSize: 0.05
                value: root.settingsState.touchpadScrollFactor
                onMoved: root.settingsState.setTouchpadScrollFactor(value)
            }

            RowLayout {
                Layout.fillWidth: true
                Text { text: "Mouse wheel speed"; color: "#cbd3dd"; font.pixelSize: 10 }
                Item { Layout.fillWidth: true }
                Text { text: root.settingsState.mouseScrollFactor.toFixed(2) + "×"; color: "#8f9aaa"; font.pixelSize: 9 }
            }

            Slider {
                Layout.fillWidth: true
                from: 0.25
                to: 2.0
                stepSize: 0.05
                value: root.settingsState.mouseScrollFactor
                onMoved: root.settingsState.setMouseScrollFactor(value)
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#242c36"
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1
                Text { text: "Three-finger gestures"; color: "#cbd3dd"; font.pixelSize: 10 }
                Text { text: "← / → workspace   •   ↑ Overview   •   ↓ close window"; color: "#697586"; font.pixelSize: 9 }
            }

            Switch {
                checked: root.settingsState.gesturesEnabled
                onToggled: root.settingsState.setGesturesEnabled(checked)
            }
        }
    }
}
