import QtQuick
import QtQuick.Layouts
import Quickshell
import "./components" as Components

ShellRoot {
    PanelWindow {
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: 52
        color: "transparent"

        Rectangle {
            id: glass
            anchors.fill: parent
            anchors.margins: 8
            radius: 20
            color: "#40363a4f"   // tint, alpha 0.25: this is the region that gets blurred

            // iOS directional light highlight, as its own layer
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#50ffffff" }
                    GradientStop { position: 0.1; color: "#00ffffff" }
                }
            }

            // Left-aligned modules
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                Components.Workspaces {}
            }

            // Centered modules
            Components.Clock {
                anchors.centerIn: parent
            }
        }
    }
}
