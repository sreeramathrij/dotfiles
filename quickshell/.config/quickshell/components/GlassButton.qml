// components/GlassButton.qml
import QtQuick

Rectangle {
    id: root
    property alias text: label.text
    property bool compact: false
    signal clicked()

    implicitWidth: label.implicitWidth + 24
    implicitHeight: compact ? 22 : 26
    radius: height / 2
    color: mouse.pressed ? "#40ffffff" : mouse.containsMouse ? "#30ffffff" : "#1fffffff"
    border.width: 1
    border.color: "#38ffffff"
    Behavior on color { ColorAnimation { duration: 120 } }

    GlassText {
        id: label
        anchors.centerIn: parent
        font.pointSize: root.compact ? 8.5 : 9
        font.weight: Font.DemiBold
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
