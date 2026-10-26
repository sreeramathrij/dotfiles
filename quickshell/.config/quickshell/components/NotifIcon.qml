// components/NotifIcon.qml
import QtQuick
import Quickshell

Rectangle {
    id: root
    property var notif: null
    property int size: 36

    implicitWidth: size
    implicitHeight: size
    radius: size / 2
    color: "#22ffffff"
    border.width: 1
    border.color: "#33ffffff"

    readonly property string src: {
        if (!notif) return ""
        if (notif.image !== "") return notif.image
        if (notif.appIcon !== "") return Quickshell.iconPath(notif.appIcon, true)
        return ""
    }

    Image {
        anchors.centerIn: parent
        width: root.size * 0.6
        height: width
        visible: root.src !== ""
        source: root.src
        fillMode: Image.PreserveAspectFit
        asynchronous: true
    }
    Text {   // fallback: bell glyph
        anchors.centerIn: parent
        visible: root.src === ""
        text: "\uf0f3"
        font.family: "JetBrainsMono Nerd Font"
        font.pointSize: 11
        color: "#f5f7ff"
    }
}
