import QtQuick

// The shared liquid-glass look. Every pill and panel uses this,
// so the whole style lives (and gets tuned) in one place.
Item {
    id: root

    property real radius: 20
    property color tint: "#201e2030"   // dark glass body; keep its alpha above Hyprland's ignore_alpha
    property real shine: 1.0           // strength of highlights and rim (1.0 = normal)
    default property alias content: slot.data

    // 1. Body tint
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: root.tint
    }

    // 2. Light from above, plus a faint bounce along the bottom edge
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        gradient: Gradient {
            GradientStop { position: 0.00; color: Qt.rgba(1, 1, 1, 0.16 * root.shine) }
            GradientStop { position: 0.35; color: Qt.rgba(1, 1, 1, 0.03 * root.shine) }
            GradientStop { position: 0.80; color: Qt.rgba(1, 1, 1, 0.00) }
            GradientStop { position: 1.00; color: Qt.rgba(1, 1, 1, 0.06 * root.shine) }
        }
    }

    // 3. Rim light: bright top-left, weaker reflection bottom-right
    Canvas {
        id: rim
        anchors.fill: parent
        renderTarget: Canvas.FramebufferObject
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        Connections {
            target: root
            function onRadiusChanged() { rim.requestPaint() }
            function onShineChanged() { rim.requestPaint() }
        }

        onPaint: {
            const ctx = getContext("2d")
            const w = width, h = height
            ctx.clearRect(0, 0, w, h)
            if (w < 4 || h < 4) return

            // gradient axis pointing down-right, so the top edge fades along its length
            const k = (0.5 * w + h) / 1.25
            const g = ctx.createLinearGradient(0, 0, 0.5 * k, k)
            const s = root.shine
            g.addColorStop(0.00, "rgba(255,255,255," + Math.min(1, 0.85 * s) + ")")
            g.addColorStop(0.30, "rgba(255,255,255," + 0.30 * s + ")")
            g.addColorStop(0.65, "rgba(255,255,255," + 0.07 * s + ")")
            g.addColorStop(1.00, "rgba(255,255,255," + 0.45 * s + ")")
            ctx.strokeStyle = g

            // soft inner glow
            const r2 = Math.max(0, root.radius - 2)
            ctx.globalAlpha = 0.22
            ctx.lineWidth = 4
            ctx.beginPath()
            ctx.roundedRect(2, 2, w - 4, h - 4, r2, r2)
            ctx.stroke()

            // crisp rim
            const r1 = Math.max(0, root.radius - 0.6)
            ctx.globalAlpha = 1
            ctx.lineWidth = 1.25
            ctx.beginPath()
            ctx.roundedRect(0.625, 0.625, w - 1.25, h - 1.25, r1, r1)
            ctx.stroke()
        }
    }

    Item { id: slot; anchors.fill: parent }
}
