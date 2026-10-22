import QtQuick
import Quickshell.Hyprland

Row {
    spacing: 12

    Repeater {
        model: Hyprland.workspaces

        Rectangle {
            id: workspaceSpace
            // Standard QML role for array items
            required property var modelData

            // Optional chaining (?.) prevents crashes when the active workspace is null on boot
            width: modelData.id === Hyprland.focusedWorkspace?.id ? 36 : 12
            height: 12
            radius: 6
            
            color: modelData.id === Hyprland.focusedWorkspace?.id ? "#7dc4e4" : "#494d64"
            
            Behavior on width { 
                NumberAnimation { duration: 300; easing.type: Easing.OutQuint } 
            }
            Behavior on color { 
                ColorAnimation { duration: 300 } 
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                // Explicitly route the click variable through the parent ID and modelData
                onClicked: Hyprland.dispatch('hl.dsp.focus({ workspace = "' + workspaceSpace.modelData.id + '" })')
            }
        }
    }
}
