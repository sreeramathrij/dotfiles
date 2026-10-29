import QtQuick
import QtQuick.Layouts

// Power action. With `confirm: true` the first click arms it (red, "Confirm"),
// the second click within 3 seconds runs it.
Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property bool confirm: false
    property bool armed: false
    readonly property color danger: "#ed8796"
    signal triggered()

    implicitHeight: 56
    radius: 18
    color: armed ? "#40ed8796" : mouse.pressed ? "#30ffffff" : mouse.containsMouse ? "#24ffffff" : "#14ffffff"
    border.width: 1
    border.color: armed ? "#80ed8796" : "#26ffffff"
    Behavior on color { ColorAnimation { duration: 120 } }

    Timer { id: disarm; interval: 3000; onTriggered: root.armed = false }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 2
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.icon
            font.family: "JetBrainsMono Nerd Font"
            font.pointSize: 13
            color: root.armed ? root.danger : "#f5f7ff"
        }
        GlassText {
            Layout.alignment: Qt.AlignHCenter
            text: root.armed ? "Confirm" : root.label
            font.pointSize: 8
            color: root.armed ? root.danger : "#c3c9e6"
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (!root.confirm || root.armed) {
                root.armed = false
                disarm.stop()
                root.triggered()
            } else {
                root.armed = true
                disarm.restart()
            }
        }
    }
}
