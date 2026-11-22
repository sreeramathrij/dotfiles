// NeoBrix animated/static wallpaper gallery.
// Uses Wall.setWallpaper(); never replaces the existing Wallpaper/Wallpaper.qml.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Theme
import qs.Components
import qs.Services

BrixPopup {
    id: root
    panel: "wallpapers"
    alignment: "center"
    contentWidth: Math.min(850, screen ? screen.width - Theme.spaceXl * 2 : 850)
    contentHeight: Math.min(580, screen ? screen.height - Theme.barExclusive * 2 : 580)

    readonly property string thumbDirectory:
        (Quickshell.env("XDG_CACHE_HOME") || Quickshell.env("HOME") + "/.cache")
        + "/neobrix/wallpaper-thumbs"

    readonly property var filtered: {
        const needle = search.text.toLowerCase().trim();
        return Wall.available.filter(path =>
            needle === "" || path.split("/").pop().toLowerCase().indexOf(needle) !== -1);
    }

    // BEGIN NB-WALLPICKER-V2-KEYBOARD
    function moveSelection(dx, dy) {
        const count = root.filtered.length;
        if (count === 0) return;
        const columns = Math.max(1, Math.floor(grid.width / grid.cellWidth));
        const current = grid.currentIndex >= 0 ? grid.currentIndex : 0;
        const next = Math.max(0, Math.min(count - 1, current + dx + dy * columns));
        grid.currentIndex = next;
        grid.positionViewAtIndex(next, GridView.Contain);
    }
    function applySelection() {
        if (root.filtered.length === 0) return;
        const idx = grid.currentIndex >= 0 ? grid.currentIndex : 0;
        if (idx >= root.filtered.length) return;
        Wall.setWallpaper(root.filtered[idx]);
        Panels.close();
    }
    onFilteredChanged: {
        if (root.filtered.length === 0) grid.currentIndex = -1;
        else if (grid.currentIndex < 0 || grid.currentIndex >= root.filtered.length)
            grid.currentIndex = 0;
    }
    // These work regardless of whether the search input or gallery has focus.
    Shortcut { sequence: "Ctrl+H"; enabled: root.open; onActivated: root.moveSelection(-1, 0) }
    Shortcut { sequence: "Ctrl+J"; enabled: root.open; onActivated: root.moveSelection(0, 1) }
    Shortcut { sequence: "Ctrl+K"; enabled: root.open; onActivated: root.moveSelection(0, -1) }
    Shortcut { sequence: "Ctrl+L"; enabled: root.open; onActivated: root.moveSelection(1, 0) }
    // END NB-WALLPICKER-V2-KEYBOARD

    onPanelOpened: {
        search.text = "";
        grid.currentIndex = root.filtered.length ? 0 : -1;
        Wall.refresh();
        search.forceActiveFocus();
    }

    BrixCard {
        anchors.fill: parent
        radius: Theme.radiusLg
        color: Theme.surfaceAlt
        shadowOffset: Theme.shadowLg

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spaceMd
            spacing: Theme.spaceMd

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "󰸉  WALLPAPERS"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontLg
                    font.weight: Theme.weightHeavy
                    color: Theme.foreground
                }
                Item { Layout.fillWidth: true }
                BrixChip {
                    text: root.filtered.length + " available"
                    accent: Theme.tertiary
                }
                BrixButton {
                    text: "REFRESH"
                    icon: "󰑐"
                    fontSize: Theme.fontXs
                    accent: Theme.surface
                    onClicked: Wall.refresh()
                }
                BrixIconButton {
                    icon: "󰅖"
                    tooltip: "Close"
                    accent: Theme.surface
                    onClicked: Panels.close()
                }
            }

            BrixCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: Theme.radiusMd
                color: Theme.surface
                shadowOffset: Theme.shadowSm
                TextInput {
                    id: search
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spaceMd
                    anchors.rightMargin: Theme.spaceMd
                    verticalAlignment: TextInput.AlignVCenter
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontMd
                    color: Theme.foreground
                    selectionColor: Theme.primary
                    selectedTextColor: Theme.onAccent
                    clip: true
                    focus: true
                    onTextChanged: grid.currentIndex = root.filtered.length ? 0 : -1
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Search wallpapers by filename…"
                        visible: search.text === ""
                        color: Theme.foregroundDim
                        font: search.font
                    }
                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.applySelection();
                            event.accepted = true;
                        }
                    }
                }
            }

            BrixCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Theme.radiusMd
                color: Theme.surface
                shadowOffset: Theme.shadowSm
                clip: true
                GridView {
                    id: grid
                    anchors.fill: parent
                    anchors.margins: Theme.spaceSm
                    cellWidth: 202
                    cellHeight: 153
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    model: root.filtered
                    delegate: Item {
                        id: card
                        required property var modelData
                        required property int index
                        width: grid.cellWidth - Theme.spaceSm
                        height: grid.cellHeight - Theme.spaceSm

                        readonly property string path: String(modelData)
                        readonly property bool isAnimated: /\.(gif|mp4|webm|mkv)$/i.test(path)
                        readonly property string thumbnailPath: root.thumbDirectory + "/" + Qt.md5(path) + ".jpg"
                        property bool thumbnailReady: false

                        Process {
                            id: thumbnailProcess
                            command: [Quickshell.env("HOME")
                                      + "/.local/share/neobrix-compatible/bin/neobrix-wall-thumb",
                                      card.path]
                            onExited: (exitCode, exitStatus) => {
                                card.thumbnailReady = exitCode === 0;
                                if (exitCode !== 0)
                                    console.warn("Wallpaper thumbnail generation failed:", card.path, exitCode);
                            }
                        }
                        Component.onCompleted: {
                            if (card.isAnimated) thumbnailProcess.running = true;
                        }

                        BrixCard {
                            anchors.fill: parent
                            radius: Theme.radiusSm
                            shadowOffset: card.path === Wall.current ? Theme.shadowSm : 0
                            border.width: card.GridView.isCurrentItem ? Theme.border + 2
                                : (card.path === Wall.current ? Theme.border : 1)
                            borderColor: card.GridView.isCurrentItem ? Theme.tertiary : Theme.outline
                            color: card.path === Wall.current ? Theme.primary : Theme.surfaceDeep
                            Rectangle {
                                id: preview
                                x: 7
                                y: 7
                                width: parent.width - 14
                                height: 99
                                color: Theme.surface
                                radius: Theme.radiusXs
                                clip: true
                                Image {
                                    anchors.fill: parent
                                    source: card.isAnimated
                                        ? (card.thumbnailReady ? "file://" + card.thumbnailPath : "")
                                        : "file://" + card.path
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: false
                                    smooth: true
                                }
                                Text {
                                    anchors.centerIn: parent
                                    visible: card.isAnimated && !card.thumbnailReady
                                    text: "GENERATING PREVIEW…"
                                    font.family: Theme.fontMono
                                    font.pixelSize: Theme.fontXs
                                    color: Theme.foregroundDim
                                }
                                Rectangle {
                                    visible: card.isAnimated
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    anchors.margins: 5
                                    width: tagText.implicitWidth + 12
                                    height: tagText.implicitHeight + 6
                                    radius: Theme.radiusXs
                                    color: Theme.primary
                                    Text {
                                        id: tagText
                                        anchors.centerIn: parent
                                        text: /\.gif$/i.test(card.path) ? "GIF" : "VIDEO"
                                        font.family: Theme.fontMono
                                        font.pixelSize: Theme.fontXs
                                        color: Theme.onAccent
                                    }
                                }
                            }
                            Text {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: preview.bottom
                                anchors.margins: 8
                                text: card.path.split("/").pop()
                                color: card.path === Wall.current ? Theme.onAccent : Theme.foreground
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontXs
                                elide: Text.ElideMiddle
                                maximumLineCount: 1
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: grid.currentIndex = card.index
                                onClicked: {
                                    grid.currentIndex = card.index;
                                    root.applySelection();
                                }
                            }
                        }
                    }
                }
                Text {
                    anchors.centerIn: parent
                    visible: root.filtered.length === 0
                    text: "NO WALLPAPERS FOUND"
                    font.family: Theme.fontMono
                    color: Theme.foregroundDim
                }
            }
            Text {
                Layout.fillWidth: true
                text: "CTRL + H/J/K/L: MOVE   •   ENTER: APPLY   •   ESC: CLOSE"
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontXs
                color: Theme.foregroundDim
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
