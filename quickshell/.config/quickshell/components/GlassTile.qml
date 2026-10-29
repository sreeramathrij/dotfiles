import QtQuick
import QtQuick.Layouts

// Toggle tile (Wi-Fi, Bluetooth): lights up with the accent colour when active.
Rectangle {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool active: false
    signal clicked()

    implicitHeight: 64
    radius: 20
    color: active ? "#4d8aadf4" : "#18ffffff"
    border.width: 1
    border.color: active ? "#668aadf4" : "#26ffffff"
    Behavior on color { ColorAnimation { duration: 160 } }
    Behavior on border.color { ColorAnimation { duration: 160 } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        Rectangle {
            Layout.preferredWidth: 34
            Layout.preferredHeight: 34
            radius: 17
            color: root.active ? "#f5f7ff" : "#26ffffff"
            Behavior on color { ColorAnimation { duration: 160 } }

            Text {
                anchors.centerIn: parent
                text: root.icon
                font.family: "JetBrainsMono Nerd Font"
                font.pointSize: 12
                color: root.active ? "#10121f" : "#f5f7ff"
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            GlassText {
                Layout.fillWidth: true
                text: root.title
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            GlassText {
                Layout.fillWidth: true
                text: root.subtitle
                color: "#c3c9e6"
                font.pointSize: 8.5
                elide: Text.ElideRight
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
