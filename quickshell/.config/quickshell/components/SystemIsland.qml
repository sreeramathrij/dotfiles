import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower

PanelWindow {
    id: win

    // ── Sizes ─────────────────────────────────────────────
    readonly property int pillH: 34
    readonly property int panelW: 360
    readonly property int panelH: 362

    implicitWidth: panelW + 40           // slack for the spring overshoot (the island grows leftwards)
    implicitHeight: panelH + 80
    anchors { top: true; right: true }
    margins.top: 10
    margins.right: 14
    exclusionMode: ExclusionMode.Ignore  // the clock island already reserves the top strip
    color: "transparent"
    mask: Region { item: island }

    // ── Palette ───────────────────────────────────────────
    readonly property color textPrimary: "#f5f7ff"
    readonly property color textSecondary: "#c3c9e6"
    readonly property color textTertiary: "#8f96b8"
    readonly property color accent: "#8aadf4"
    readonly property string iconFont: "JetBrainsMono Nerd Font"

    // ── Open / close ──────────────────────────────────────
    property bool hovered: false
    readonly property bool expanded: hovered
    Timer { id: leaveTimer; interval: 250; onTriggered: win.hovered = false }

    // ── Wi-Fi ─────────────────────────────────────────────
    readonly property var wifiDevice: {
        const devs = Networking.devices.values
        for (let i = 0; i < devs.length; i++)
            if (devs[i].type === DeviceType.Wifi) return devs[i]
        return devs.length > 0 ? devs[0] : null
    }
    readonly property var wifiNetwork: wifiDevice ? (wifiDevice.networks.values.find(n => n.connected) || null) : null
    readonly property bool wifiOn: Networking.wifiEnabled
    readonly property string wifiText: !wifiOn ? "Off" : wifiNetwork ? wifiNetwork.name : "Not connected"

    // ── Bluetooth ─────────────────────────────────────────
    readonly property var btAdapter: Bluetooth.defaultAdapter
    readonly property bool btOn: btAdapter ? btAdapter.enabled : false
    readonly property var btConnected: {          // connected devices across all adapters
        const d = Bluetooth.devices
        return d ? (d.values !== undefined ? d.values : d) : []
    }
    readonly property string btText: !btOn ? "Off"
        : btConnected.length === 0 ? "On"
        : btConnected[0].name + (btConnected.length > 1 ? " +" + (btConnected.length - 1) : "")

    // ── Audio ─────────────────────────────────────────────
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null
    readonly property real vol: audio ? audio.volume : 0
    readonly property bool muted: audio ? audio.muted : false
    readonly property string volIcon: (muted || vol === 0) ? "\uf026" : vol < 0.5 ? "\uf027" : "\uf028"
    PwObjectTracker { objects: win.sink ? [win.sink] : [] }

    // ── Battery ───────────────────────────────────────────
    readonly property var bat: UPower.displayDevice
    readonly property bool hasBat: !!bat && bat.ready
    readonly property real batPct: {
        if (!bat) return 0
        const p = bat.percentage          // I believe this is 0..1; the guard also accepts 0..100
        return p > 1 ? p : p * 100
    }
    readonly property bool charging: !!bat && (bat.state === UPowerDeviceState.Charging
                                               || bat.state === UPowerDeviceState.FullyCharged)
    readonly property string batIcon: charging ? "\uf0e7"
        : batPct > 87 ? "\uf240" : batPct > 62 ? "\uf241"
        : batPct > 37 ? "\uf242" : batPct > 12 ? "\uf243" : "\uf244"
    readonly property color batColor: charging ? "#a6da95" : batPct <= 15 ? "#ed8796" : textPrimary

    // ── CPU / RAM (sampled every 2 s, only while the panel is open) ──
    property real cpuFrac: 0
    property real ramFrac: 0
    property real ramUsedGb: 0
    property real prevTotal: 0
    property real prevIdle: 0

    Process {
        id: statProc
        command: ["sh", "-c", "head -n1 /proc/stat; grep -E '^(MemTotal|MemAvailable):' /proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.split("\n")
                const f = lines[0].trim().split(/\s+/).slice(1).map(Number)
                const idle = f[3] + f[4]
                const total = f.reduce((a, b) => a + b, 0)
                if (win.prevTotal > 0 && total > win.prevTotal)
                    win.cpuFrac = 1 - (idle - win.prevIdle) / (total - win.prevTotal)
                win.prevTotal = total
                win.prevIdle = idle

                let memTotal = 0, memAvail = 0
                for (const l of lines) {
                    if (l.startsWith("MemTotal:")) memTotal = parseInt(l.split(/\s+/)[1])
                    else if (l.startsWith("MemAvailable:")) memAvail = parseInt(l.split(/\s+/)[1])
                }
                if (memTotal > 0) {
                    win.ramUsedGb = (memTotal - memAvail) / 1048576
                    win.ramFrac = (memTotal - memAvail) / memTotal
                }
            }
        }
    }
    Timer {
        interval: 2000
        running: win.expanded
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!statProc.running) statProc.running = true
    }

    // ── Brightness (via brightnessctl) ────────────────────
    property real brightness: 0.5

    Process {
        id: brightGet
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = this.text.trim().split(",")      // name,class,current,percent,max
                if (p.length >= 4) win.brightness = parseInt(p[3]) / 100
            }
        }
    }
    Timer {
        id: brightApply
        interval: 80                                       // debounce while dragging
        onTriggered: Quickshell.execDetached(["brightnessctl", "set", Math.round(win.brightness * 100) + "%"])
    }
    onExpandedChanged: if (expanded) brightGet.running = true

    // ── The island ────────────────────────────────────────
    GlassSurface {
        id: island
        anchors.top: parent.top
        anchors.right: parent.right
        clip: true

        width: win.expanded ? win.panelW : compactRow.implicitWidth + 28
        height: win.expanded ? win.panelH : win.pillH
        radius: Math.max(0, Math.min(height / 2, 32))
        shine: win.expanded ? 1.25 : 1.0
        tint: win.expanded ? "#2a1e2030" : "#201e2030"

        Behavior on width  { SpringAnimation { spring: 3.2; damping: 0.32; epsilon: 0.25 } }
        Behavior on height { SpringAnimation { spring: 3.6; damping: 0.36; epsilon: 0.25 } }
        Behavior on tint   { ColorAnimation { duration: 300 } }

        HoverHandler {
            onHoveredChanged: {
                if (hovered) { leaveTimer.stop(); win.hovered = true }
                else leaveTimer.restart()
            }
        }

        // ── Compact: status icons ──
        Row {
            id: compactRow
            anchors.centerIn: parent
            spacing: 12
            opacity: win.expanded ? 0 : 1
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 140 } }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "\uf1eb"
                font.family: win.iconFont
                font.pointSize: 11
                color: !win.wifiOn ? "#494d64" : win.wifiNetwork ? win.textPrimary : win.textTertiary
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "\uf293"
                font.family: win.iconFont
                font.pointSize: 11
                color: !win.btOn ? "#494d64" : win.btConnected.length > 0 ? win.accent : win.textTertiary
            }
            Row {
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: win.volIcon
                    font.family: win.iconFont
                    font.pointSize: 11
                    color: win.muted ? "#6e738d" : win.textPrimary
                }
                GlassText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: win.muted ? "mute" : Math.round(win.vol * 100) + "%"
                    font.pointSize: 9.5
                }
            }
            Row {
                spacing: 5
                visible: win.hasBat
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: win.batIcon
                    font.family: win.iconFont
                    font.pointSize: 11
                    color: win.batColor
                }
                GlassText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Math.round(win.batPct) + "%"
                    font.pointSize: 9.5
                }
            }
        }

        // ── Expanded: control panel ──
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12
            opacity: win.expanded ? 1 : 0
            visible: opacity > 0
            Behavior on opacity {
                SequentialAnimation {
                    PauseAnimation { duration: win.expanded ? 140 : 0 }   // let the glass grow first
                    NumberAnimation { duration: 200 }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                GlassTile {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    icon: "\uf1eb"
                    title: "Wi-Fi"
                    subtitle: win.wifiText
                    active: win.wifiOn
                    onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                }
                GlassTile {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    icon: "\uf293"
                    title: "Bluetooth"
                    subtitle: win.btText
                    active: win.btOn
                    onClicked: if (win.btAdapter) win.btAdapter.enabled = !win.btAdapter.enabled
                }
            }

            GlassSlider {
                Layout.fillWidth: true
                icon: win.volIcon
                value: win.muted ? 0 : win.vol
                onMoved: v => {
                    if (!win.audio) return
                    win.audio.muted = false
                    win.audio.volume = v
                }
            }

            GlassSlider {
                Layout.fillWidth: true
                icon: "\uf185"
                value: win.brightness
                onMoved: v => {
                    win.brightness = Math.max(0.01, v)     // never 0: some panels go fully black
                    brightApply.restart()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                StatTile {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    visible: win.hasBat
                    icon: win.batIcon
                    label: win.charging ? "Charging" : "Battery"
                    value: Math.round(win.batPct) + "%"
                    fraction: win.batPct / 100
                    tint: win.batColor === win.textPrimary ? win.accent : win.batColor
                }
                StatTile {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    icon: "\uf2db"
                    label: "RAM"
                    value: win.ramUsedGb.toFixed(1) + " GB"
                    fraction: win.ramFrac
                    tint: "#c6a0f6"
                }
                StatTile {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    icon: "\uf0e4"
                    label: "CPU"
                    value: Math.round(win.cpuFrac * 100) + "%"
                    fraction: win.cpuFrac
                    tint: "#f5a97f"
                }
            }

            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: "#22ffffff" }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                PowerButton {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    icon: "\uf023"
                    label: "Lock"
                    onTriggered: Quickshell.execDetached(["hyprlock"])
                }
                PowerButton {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    icon: "\uf08b"
                    label: "Log out"
                    confirm: true
                    onTriggered: Quickshell.execDetached(["sh", "-c",
                        "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"])
                }
                PowerButton {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    icon: "\uf021"
                    label: "Reboot"
                    confirm: true
                    onTriggered: Quickshell.execDetached(["systemctl", "reboot"])
                }
                PowerButton {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    icon: "\uf011"
                    label: "Shut down"
                    confirm: true
                    onTriggered: Quickshell.execDetached(["systemctl", "poweroff"])
                }
            }
        }
    }
}
