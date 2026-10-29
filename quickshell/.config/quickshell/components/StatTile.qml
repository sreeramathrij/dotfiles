import QtQuick
import QtQuick.Layouts

// Small read-only tile: icon, label, value and a thin bar.
Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property string value: ""
    property real fraction: 0           // 0..1
    property color tint: "#8aadf4"

    implicitHeight: 62
    radius: 18
    color: "#14ffffff"
    border.width: 1
    border.color: "#22ffffff"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 3

        RowLayout {
            spacing: 6
            Text {
                text: root.icon
                font.family: "JetBrainsMono Nerd Font"
                font.pointSize: 9
                color: root.tint
            }
            GlassText { text: root.label; color: "#8f96b8"; font.pointSize: 8 }
        }

        GlassText { text: root.value; font.pointSize: 11; font.weight: Font.DemiBold }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 4
            radius: 2
            color: "#22ffffff"
            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, root.fraction))
                height: parent.height
                radius: 2
                color: root.tint
                Behavior on width { NumberAnimation { duration: 300 } }
            }
        }
    }
}
