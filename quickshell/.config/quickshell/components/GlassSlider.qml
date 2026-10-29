import QtQuick

// iOS-style pill slider: the fill grows from the left and the icon sits on the fill.
Item {
    id: root

    property real value: 0              // 0..1
    property string icon: ""
    signal moved(real value)

    implicitHeight: 40

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: "#1affffff"
        border.width: 1
        border.color: "#26ffffff"
        clip: true

        Rectangle {
            width: Math.max(parent.height, parent.width * root.value)
            height: parent.height
            radius: height / 2
            color: "#e6f5f7ff"
            Behavior on width { enabled: !area.pressed; NumberAnimation { duration: 120 } }
        }
    }

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        text: root.icon
        color: "#10121f"
        font.family: "JetBrainsMono Nerd Font"
        font.pointSize: 11
    }

    MouseArea {
        id: area
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        function setFrom(x) { root.moved(Math.max(0, Math.min(1, x / width))) }

        onPressed: mouse => setFrom(mouse.x)
        onPositionChanged: mouse => { if (pressed) setFrom(mouse.x) }
        onWheel: wheel => root.moved(Math.max(0, Math.min(1, root.value + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))))
    }
}
