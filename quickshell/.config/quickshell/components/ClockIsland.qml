import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications

PanelWindow {
    id: win

    // ── Sizes ─────────────────────────────────────────────
    readonly property int pillW: 232
    readonly property int pillH: 34
    readonly property int panelW: 520
    readonly property int panelH: 380
    readonly property int toastW: 392

    implicitWidth: panelW + 80           // slack so the spring overshoot isn't clipped
    implicitHeight: panelH + 80
    anchors.top: true                    // top only: centred horizontally
    margins.top: 10
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: pillH                 // reserves margin + pill height at the top of the screen
    color: "transparent"
    mask: Region { item: island }        // everything outside the glass is click-through

    // ── Palette ───────────────────────────────────────────
    readonly property color textPrimary: "#f5f7ff"
    readonly property color textSecondary: "#c3c9e6"
    readonly property color textTertiary: "#8f96b8"
    readonly property color accent: "#8aadf4"

    // ── State ─────────────────────────────────────────────
    property bool hovered: false
    property var activeToast: null
    readonly property bool expanded: hovered
    readonly property bool showingToast: activeToast !== null && !expanded
    readonly property bool toastHasButtons: activeToast !== null && activeToast.actions.length > 0
    readonly property int alertCount: server.trackedNotifications.values.length

    // Newest first
    readonly property var notifications: {
        const src = server.trackedNotifications.values
        const out = []
        for (let i = src.length - 1; i >= 0; i--) out.push(src[i])
        return out
    }

    // ── Logic ─────────────────────────────────────────────
    function clearToast(n) { if (activeToast === n) activeToast = null }

    function clearAll() {
        const all = server.trackedNotifications.values
        for (let i = all.length - 1; i >= 0; i--) all[i].dismiss()
    }

    function invokeAction(n, action) {
        if (!n || !action) return
        action.invoke()
        clearToast(n)
        n.dismiss()
    }

    // Click on a notification body: default action, else a sensible fallback
    function activate(n) {
        if (!n) return
        let done = false
        for (let i = 0; i < n.actions.length; i++) {
            if (n.actions[i].identifier === "default") {
                n.actions[i].invoke()
                done = true
                break
            }
        }
        if (!done && n.actions.length === 1) {
            n.actions[0].invoke()
            done = true
        }
        if (!done) {
            const app = (n.appName || "").toLowerCase()
            const entry = n.desktopEntry || ""
            if (app.indexOf("kde connect") !== -1 || entry.toLowerCase().indexOf("kdeconnect") !== -1)
                Hyprland.dispatch('hl.dsp.exec_cmd("kdeconnect-app")')
            else if (entry !== "")
                Hyprland.dispatch('hl.dsp.exec_cmd("gtk-launch ' + entry + '")')
        }
        clearToast(n)
        n.dismiss()
    }

    Timer { id: toastTimer; interval: 6000; onTriggered: win.activeToast = null }
    Timer { id: leaveTimer; interval: 220; onTriggered: win.hovered = false }

    SystemClock {
        id: clock
        precision: win.expanded ? SystemClock.Seconds : SystemClock.Minutes
    }

    NotificationServer {
        id: server
        keepOnReload: true
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        onNotification: n => {
            n.tracked = true
            if (n.lastGeneration) return      // don't pop toasts for notifications restored on reload
            win.activeToast = n
            toastTimer.restart()
        }
    }

    // ── The island ────────────────────────────────────────
    GlassSurface {
        id: island
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        clip: true

        width: win.expanded ? win.panelW : win.showingToast ? win.toastW : win.pillW
        height: win.expanded ? win.panelH
              : win.showingToast ? (win.toastHasButtons ? 112 : 76) : win.pillH
        radius: Math.max(0, Math.min(height / 2, win.expanded ? 32 : 26))
        shine: win.expanded ? 1.25 : 1.0
        tint: (win.expanded || win.showingToast) ? "#2a1e2030" : "#201e2030"

        // Liquid feel: springs instead of fixed-duration easing
        Behavior on width  { SpringAnimation { spring: 3.2; damping: 0.32; epsilon: 0.25 } }
        Behavior on height { SpringAnimation { spring: 3.6; damping: 0.36; epsilon: 0.25 } }
        Behavior on tint   { ColorAnimation { duration: 300 } }

        HoverHandler {
            onHoveredChanged: {
                if (hovered) { leaveTimer.stop(); win.hovered = true }
                else leaveTimer.restart()
            }
        }

        // ── State 1: compact pill ──
        Row {
            anchors.centerIn: parent
            spacing: 10
            opacity: (!win.expanded && !win.showingToast) ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 140 } }

            GlassText {
                text: Qt.formatDateTime(clock.date, "ddd, MMM d")
                color: win.textSecondary
            }
            GlassText {
                text: Qt.formatDateTime(clock.date, "hh:mm AP")
                font.weight: Font.DemiBold
            }
        }

        // ── State 2: notification toast ──
        Item {
            anchors.fill: parent
            opacity: win.showingToast ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 180 } }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        const n = win.activeToast
                        win.activeToast = null
                        if (n) n.dismiss()
                    } else {
                        win.activate(win.activeToast)
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                anchors.topMargin: 12
                anchors.bottomMargin: 12
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    NotifIcon { notif: win.activeToast; size: 38 }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        GlassText {
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            font.weight: Font.Bold
                            text: win.activeToast ? (win.activeToast.summary || win.activeToast.appName) : ""
                        }
                        GlassText {
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            color: win.textSecondary
                            font.pointSize: 9.5
                            textFormat: Text.StyledText
                            text: win.activeToast ? win.activeToast.body : ""
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    visible: win.toastHasButtons

                    Repeater {
                        model: win.activeToast ? win.activeToast.actions : []
                        GlassButton {
                            required property var modelData
                            Layout.fillWidth: true
                            text: modelData.text || modelData.identifier
                            onClicked: win.invokeAction(win.activeToast, modelData)
                        }
                    }
                }
            }
        }

        // ── State 3: expanded dashboard ──
        ColumnLayout {
            id: dash
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14
            opacity: win.expanded ? 1 : 0
            visible: opacity > 0
            Behavior on opacity {
                SequentialAnimation {
                    PauseAnimation { duration: win.expanded ? 140 : 0 }   // let the glass grow first
                    NumberAnimation { duration: 200 }
                }
            }

            readonly property int monthDays: new Date(clock.date.getFullYear(), clock.date.getMonth() + 1, 0).getDate()
            readonly property int firstOffset: new Date(clock.date.getFullYear(), clock.date.getMonth(), 1).getDay()

            // Header: time, date, clear button
            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 0
                    RowLayout {
                        spacing: 6
                        GlassText {
                            text: Qt.formatDateTime(clock.date, "hh:mm:ss")
                            font.pointSize: 26
                            font.weight: Font.DemiBold
                        }
                        GlassText {
                            Layout.alignment: Qt.AlignBottom
                            Layout.bottomMargin: 5
                            text: Qt.formatDateTime(clock.date, "AP")
                            color: win.accent
                            font.pointSize: 11
                            font.weight: Font.DemiBold
                        }
                    }
                    GlassText {
                        text: Qt.formatDateTime(clock.date, "dddd, MMMM d, yyyy")
                        color: win.textSecondary
                    }
                }

                Item { Layout.fillWidth: true }

                GlassButton {
                    text: win.alertCount > 0 ? "Clear " + win.alertCount : "No alerts"
                    onClicked: win.clearAll()
                }
            }

            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: "#22ffffff" }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 14

                // Calendar card
                Rectangle {
                    Layout.preferredWidth: 224
                    Layout.fillHeight: true
                    radius: 20
                    color: "#14ffffff"
                    border.width: 1
                    border.color: "#22ffffff"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 4

                        GlassText {
                            text: Qt.formatDateTime(clock.date, "MMMM yyyy")
                            font.weight: Font.DemiBold
                            font.pointSize: 10.5
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 7
                            rowSpacing: 0
                            columnSpacing: 0
                            Repeater {
                                model: ["S", "M", "T", "W", "T", "F", "S"]
                                GlassText {
                                    required property string modelData
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                    text: modelData
                                    color: win.textTertiary
                                    font.pointSize: 8.5
                                    font.weight: Font.DemiBold
                                }
                            }
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            columns: 7
                            rowSpacing: 0
                            columnSpacing: 0
                            Repeater {
                                model: 42
                                Item {
                                    id: cell
                                    required property int index
                                    readonly property int dayNum: index - dash.firstOffset + 1
                                    readonly property bool valid: dayNum >= 1 && dayNum <= dash.monthDays
                                    readonly property bool today: valid && dayNum === clock.date.getDate()
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 24; height: 24; radius: 12
                                        color: win.accent
                                        visible: cell.today
                                    }
                                    GlassText {
                                        anchors.centerIn: parent
                                        visible: cell.valid
                                        text: cell.dayNum
                                        color: cell.today ? "#10121f" : win.textPrimary
                                        font.pointSize: 9
                                        font.weight: cell.today ? Font.Bold : Font.Normal
                                    }
                                }
                            }
                        }
                    }
                }

                // Notifications card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 20
                    color: "#14ffffff"
                    border.width: 1
                    border.color: "#22ffffff"
                    clip: true

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2
                        visible: win.alertCount === 0
                        GlassText {
                            Layout.alignment: Qt.AlignHCenter
                            text: "All clear"
                            font.weight: Font.DemiBold
                            font.pointSize: 11
                        }
                        GlassText {
                            Layout.alignment: Qt.AlignHCenter
                            text: "No new notifications"
                            color: win.textTertiary
                            font.pointSize: 9
                        }
                    }

                    ListView {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8
                        clip: true
                        model: win.notifications

                        delegate: Rectangle {
                            id: card
                            required property var modelData

                            width: ListView.view.width
                            height: cardRow.implicitHeight + 20
                            radius: 14
                            color: cardMouse.containsMouse ? "#2affffff" : "#1affffff"
                            border.width: 1
                            border.color: cardMouse.containsMouse ? "#40ffffff" : "#26ffffff"
                            Behavior on color { ColorAnimation { duration: 140 } }
                            Behavior on border.color { ColorAnimation { duration: 140 } }

                            MouseArea {
                                id: cardMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                cursorShape: Qt.PointingHandCursor
                                onClicked: mouse => {
                                    if (mouse.button === Qt.RightButton) card.modelData.dismiss()
                                    else win.activate(card.modelData)
                                }
                            }

                            RowLayout {
                                id: cardRow
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 10
                                spacing: 10

                                NotifIcon {
                                    notif: card.modelData
                                    size: 30
                                    Layout.alignment: Qt.AlignTop
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    GlassText {
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                        font.weight: Font.DemiBold
                                        font.pointSize: 9.5
                                        text: card.modelData.summary || card.modelData.appName
                                    }
                                    GlassText {
                                        Layout.fillWidth: true
                                        visible: text !== ""
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 2
                                        elide: Text.ElideRight
                                        color: win.textSecondary
                                        font.pointSize: 8.5
                                        textFormat: Text.StyledText
                                        text: card.modelData.body
                                    }
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 6
                                        visible: card.modelData.actions.length > 0
                                        Repeater {
                                            model: card.modelData.actions
                                            GlassButton {
                                                required property var modelData
                                                compact: true
                                                Layout.fillWidth: true
                                                text: modelData.text || modelData.identifier
                                                onClicked: win.invokeAction(card.modelData, modelData)
                                            }
                                        }
                                    }
                                }

                                GlassText {
                                    Layout.alignment: Qt.AlignTop
                                    text: "\u2715"
                                    color: closeMouse.containsMouse ? win.textPrimary : win.textTertiary
                                    font.pointSize: 9
                                    MouseArea {
                                        id: closeMouse
                                        anchors.fill: parent
                                        anchors.margins: -6
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: card.modelData.dismiss()
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
