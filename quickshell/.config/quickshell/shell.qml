import QtQuick
import Quickshell
import Quickshell.Wayland
import "./components" as Components

ShellRoot {
    PanelWindow {
        id: barWindow
        anchors {
            top: true
            left: true
            right: true
        }
        
        // Tall enough to render the expanded dropdown without clipping
        implicitHeight: 340
        
        // Only reserve 48px of screen real estate at the top for tiled windows
        exclusiveZone: 48
        color: "transparent"

        // Crucial: Only capture mouse hover/clicks inside the visible glass island(s).
        // Everything else passes clicks directly through to your Hyprland windows.
        mask: Region {
            item: centerClock.glassItem
        }

        // [dynamic date-time] Center Island
        Components.Clock {
            id: centerClock
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
