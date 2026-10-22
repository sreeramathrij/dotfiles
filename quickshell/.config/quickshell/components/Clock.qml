import QtQuick

Text {
    id: timeText
    anchors.centerIn: parent
    text: Qt.formatDateTime(new Date(), "ddd, MMM d hh:mm A")
    color: "#cad3f5" // Catpuccin Macchiato text color
    font.pointSize: 11
    font.weight: Font.DemiBold
    font.letterSpacing: 0.5

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: timeText.text = Qt.formatDateTime(new Date(), "ddd, MMM d   hh:mm A")
    }
}
