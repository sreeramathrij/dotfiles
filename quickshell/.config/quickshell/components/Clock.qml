import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Services.Notifications

Item {
    id: root

    readonly property alias glassItem: island

    property bool expanded: hoverHandler.hovered
    property var activeToast: null
    property bool showingToast: activeToast !== null && !expanded
    property date currentDate: new Date()

    implicitWidth: island.width
    implicitHeight: island.height

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.currentDate = new Date()
    }

    // Extended to 6 seconds so you have plenty of time to click "Accept" on pairing requests
    Timer {
        id: toastTimer
        interval: 6000
        repeat: false
        onTriggered: root.activeToast = null
    }

    NotificationServer {
        id: notifServer
        keepOnReload: true
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true

        onNotification: function(n) {
            n.tracked = true
            root.activeToast = n
            toastTimer.restart()
        }
    }

    // Invokes a specific action button (like KDE Connect "Accept" / "Reject")
    function invokeAction(n, actionObj) {
        if (!n || !actionObj) return
        actionObj.invoke()
        if (root.activeToast === n) {
            root.activeToast = null
        }
        n.dismiss()
    }

    // Replicates mako click + desktop entry fallback for daemon notifications
    function activateNotification(n) {
        if (!n) return
        var invoked = false

        // 1. Try standard "default" action
        for (var i = 0; i < n.actions.length; i++) {
            if (n.actions[i].identifier === "default") {
                n.actions[i].invoke()
                invoked = true
                break
            }
        }

        // 2. If there is only a single action, invoke it
        if (!invoked && n.actions.length === 1) {
            n.actions[0].invoke()
            invoked = true
        }

        // 3. Fallback for background daemons (like KDE Connect) when body is clicked
        if (!invoked) {
            var app = (n.appName || "").toLowerCase()
            var entry = (n.desktopEntry || "").toLowerCase()
            if (app.indexOf("kde connect") !== -1 || entry.indexOf("kdeconnect") !== -1) {
                Hyprland.dispatch('hl.dsp.exec_cmd("kdeconnect-app")')
            } else if (n.desktopEntry && n.desktopEntry !== "") {
                Hyprland.dispatch('hl.dsp.exec_cmd("gtk-launch ' + n.desktopEntry + '")')
            }
        }

        if (root.activeToast === n) {
            root.activeToast = null
        }
        n.dismiss()
    }

    function daysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate()
    }

    function firstDayOffset(year, month) {
        return new Date(year, month, 1).getDay()
    }

    Rectangle {
        id: island
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        property bool toastHasButtons: root.activeToast && root.activeToast.actions.length > 0

        width: root.expanded ? 500 : (root.showingToast ? 380 : 210)
        height: root.expanded ? 310 : (root.showingToast ? (toastHasButtons ? 104 : 74) : 36)
        radius: root.expanded ? 28 : (root.showingToast ? 24 : 18)
        clip: true

        color: (root.expanded || root.showingToast) ? "#381e2030" : "#281e2030"

        Behavior on width { NumberAnimation { duration: 420; easing.type: Easing.OutBack; easing.overshoot: 0.6 } }
        Behavior on height { NumberAnimation { duration: 420; easing.type: Easing.OutQuint } }
        Behavior on radius { NumberAnimation { duration: 350; easing.type: Easing.OutQuint } }
        Behavior on color { ColorAnimation { duration: 300 } }

        // LAYER 1: Inner Volume Refraction
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#45ffffff" }
                GradientStop { position: 0.12; color: "#12ffffff" }
                GradientStop { position: 0.85; color: "#05000000" }
                GradientStop { position: 1.0; color: "#25ffffff" }
            }
        }

        // LAYER 2: Specular Rim Border
        Canvas {
            id: rimCanvas
            anchors.fill: parent
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                var r = island.radius
                var grad = ctx.createLinearGradient(0, 0, width * 0.4, height)
                grad.addColorStop(0.0, "rgba(255, 255, 255, 0.75)")
                grad.addColorStop(0.35, "rgba(255, 255, 255, 0.18)")
                grad.addColorStop(0.7, "rgba(255, 255, 255, 0.05)")
                grad.addColorStop(1.0, "rgba(255, 255, 255, 0.35)")

                ctx.strokeStyle = grad
                ctx.lineWidth = 1.5
                ctx.beginPath()
                ctx.roundedRect(0.75, 0.75, width - 1.5, height - 1.5, r, r)
                ctx.stroke()
            }
        }

        // ─── STATE 1: COMPACT PILL ───
        Text {
            anchors.centerIn: parent
            visible: opacity > 0
            opacity: (!root.expanded && !root.showingToast) ? 1.0 : 0.0
            text: Qt.formatDateTime(root.currentDate, "ddd, MMM d   hh:mm AP")
            color: "#f4f6ff"
            font.pointSize: 10.5
            font.weight: Font.DemiBold
            font.letterSpacing: 0.4

            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        // ─── STATE 2: DYNAMIC ISLAND TOAST POPUP ───
        Item {
            anchors.fill: parent
            visible: opacity > 0
            opacity: root.showingToast ? 1.0 : 0.0

            Behavior on opacity { NumberAnimation { duration: 200 } }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: function(mouse) {
                    if (mouse.button === Qt.RightButton) {
                        if (root.activeToast) root.activeToast.dismiss()
                        root.activeToast = null
                    } else {
                        root.activateNotification(root.activeToast)
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                anchors.topMargin: 12
                anchors.bottomMargin: 12
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 38
                        Layout.preferredHeight: 38
                        radius: 19
                        color: "#358aadf4"
                        border.width: 1
                        border.color: "#80ffffff"
                        Text {
                            anchors.centerIn: parent
                            text: "🔔"
                            font.pointSize: 13
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: root.activeToast ? (root.activeToast.summary || root.activeToast.appName) : ""
                            color: "#ffffff"
                            font.pointSize: 10.5
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        Text {
                            text: root.activeToast ? root.activeToast.body : ""
                            color: "#cad3f5"
                            font.pointSize: 9.5
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }

                // Inline Action Buttons (e.g., KDE Connect "Accept" / "Reject")
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    visible: root.activeToast !== null && root.activeToast.actions.length > 0

                    Repeater {
                        model: root.activeToast ? root.activeToast.actions : []
                        Rectangle {
                            id: toastActionBtn
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 24
                            radius: 8
                            color: toastBtnMouse.containsMouse ? "#458aadf4" : "#25ffffff"
                            border.width: 1
                            border.color: "#50ffffff"
                            z: 3

                            Text {
                                anchors.centerIn: parent
                                text: toastActionBtn.modelData.text || toastActionBtn.modelData.identifier
                                color: "#ffffff"
                                font.pointSize: 8.5
                                font.weight: Font.DemiBold
                            }

                            MouseArea {
                                id: toastBtnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.invokeAction(root.activeToast, toastActionBtn.modelData)
                            }
                        }
                    }
                }
            }
        }

        // ─── STATE 3: EXPANDED DASHBOARD ───
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14
            visible: opacity > 0
            opacity: root.expanded ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
            }

            RowLayout {
                Layout.fillWidth: true
                ColumnLayout {
                    spacing: 2
                    Text {
                        text: Qt.formatDateTime(root.currentDate, "hh:mm:ss AP")
                        color: "#ffffff"
                        font.pointSize: 22
                        font.weight: Font.Bold
                        font.letterSpacing: 0.8
                    }
                    Text {
                        text: Qt.formatDateTime(root.currentDate, "dddd, MMMM d, yyyy")
                        color: "#b8c0e0"
                        font.pointSize: 10
                        font.weight: Font.Medium
                    }
                }
                Item { Layout.fillWidth: true }

                Rectangle {
                    implicitWidth: badgeText.implicitWidth + 18
                    implicitHeight: 26
                    radius: 13
                    color: "#25ffffff"
                    border.width: 1
                    border.color: "#40ffffff"
                    Text {
                        id: badgeText
                        anchors.centerIn: parent
                        text: notifServer.trackedNotifications.values.length + " Alerts"
                        color: "#ffffff"
                        font.pointSize: 9.5
                        font.weight: Font.DemiBold
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var list = notifServer.trackedNotifications.values
                            for (var i = list.length - 1; i >= 0; i--) {
                                list[i].dismiss()
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#28ffffff"
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 16

                // ── Calendar Card ──
                Rectangle {
                    Layout.preferredWidth: 215
                    Layout.fillHeight: true
                    radius: 18
                    color: "#18ffffff"
                    border.width: 1
                    border.color: "#28ffffff"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 6

                        GridLayout {
                            columns: 7
                            Layout.fillWidth: true
                            Repeater {
                                model: ["S", "M", "T", "W", "T", "F", "S"]
                                Text {
                                    required property string modelData
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                    text: modelData
                                    color: "#8aadf4"
                                    font.pointSize: 8.5
                                    font.weight: Font.Bold
                                }
                            }
                        }

                        GridLayout {
                            columns: 7
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            rowSpacing: 2
                            columnSpacing: 2

                            Repeater {
                                model: 42
                                Rectangle {
                                    required property int index
                                    property int offset: root.firstDayOffset(root.currentDate.getFullYear(), root.currentDate.getMonth())
                                    property int totalDays: root.daysInMonth(root.currentDate.getFullYear(), root.currentDate.getMonth())
                                    property int dayNum: index - offset + 1
                                    property bool isValid: dayNum >= 1 && dayNum <= totalDays
                                    property bool isToday: isValid && dayNum === root.currentDate.getDate()

                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: 10
                                    color: isToday ? "#558aadf4" : "transparent"
                                    border.width: isToday ? 1 : 0
                                    border.color: "#90ffffff"

                                    Text {
                                        anchors.centerIn: parent
                                        visible: parent.isValid
                                        text: parent.dayNum
                                        color: parent.isToday ? "#ffffff" : "#cad3f5"
                                        font.pointSize: 8.5
                                        font.weight: parent.isToday ? Font.Bold : Font.Normal
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Notifications Feed ──
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 18
                    color: "#18ffffff"
                    border.width: 1
                    border.color: "#28ffffff"
                    clip: true

                    ColumnLayout {
                        anchors.centerIn: parent
                        visible: notifServer.trackedNotifications.values.length === 0
                        spacing: 4
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "All Clear"
                            color: "#ffffff"
                            font.pointSize: 11
                            font.weight: Font.DemiBold
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "No new notifications"
                            color: "#939ab7"
                            font.pointSize: 9
                        }
                    }

                    ListView {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8
                        model: notifServer.trackedNotifications
                        clip: true

                        delegate: Rectangle {
                            id: notifCard
                            required property var modelData
                            property bool hasButtons: modelData.actions.length > 0

                            width: ListView.view.width
                            height: hasButtons ? 82 : 54
                            radius: 12
                            color: cardMouse.containsMouse ? "#32ffffff" : "#22ffffff"
                            border.width: 1
                            border.color: cardMouse.containsMouse ? "#55ffffff" : "#30ffffff"

                            Behavior on color { ColorAnimation { duration: 150 } }
                            Behavior on border.color { ColorAnimation { duration: 150 } }

                            MouseArea {
                                id: cardMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                cursorShape: Qt.PointingHandCursor
                                onClicked: function(mouse) {
                                    if (mouse.button === Qt.RightButton) {
                                        notifCard.modelData.dismiss()
                                    } else {
                                        root.activateNotification(notifCard.modelData)
                                    }
                                }
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 4

                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: notifCard.modelData.summary || notifCard.modelData.appName
                                        color: "#ffffff"
                                        font.pointSize: 9.5
                                        font.weight: Font.Bold
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                    Text {
                                        text: "✕"
                                        color: closeMouse.containsMouse ? "#ffffff" : "#a5adcb"
                                        font.pointSize: 9
                                        z: 2
                                        MouseArea {
                                            id: closeMouse
                                            anchors.fill: parent
                                            anchors.margins: -4
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: notifCard.modelData.dismiss()
                                        }
                                    }
                                }
                                Text {
                                    text: notifCard.modelData.body
                                    color: "#cad3f5"
                                    font.pointSize: 8.5
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                // Inline Action Buttons inside Expanded List
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 6
                                    visible: notifCard.hasButtons

                                    Repeater {
                                        model: notifCard.modelData.actions
                                        Rectangle {
                                            id: cardActionBtn
                                            required property var modelData
                                            Layout.fillWidth: true
                                            implicitHeight: 20
                                            radius: 6
                                            color: cardBtnMouse.containsMouse ? "#458aadf4" : "#25ffffff"
                                            border.width: 1
                                            border.color: "#45ffffff"
                                            z: 3

                                            Text {
                                                anchors.centerIn: parent
                                                text: cardActionBtn.modelData.text || cardActionBtn.modelData.identifier
                                                color: "#ffffff"
                                                font.pointSize: 8
                                                font.weight: Font.DemiBold
                                            }

                                            MouseArea {
                                                id: cardBtnMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: root.invokeAction(notifCard.modelData, cardActionBtn.modelData)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        HoverHandler {
            id: hoverHandler
        }
    }
}
