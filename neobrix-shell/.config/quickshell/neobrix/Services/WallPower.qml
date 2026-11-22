pragma Singleton
// Optional performance policy: one (not per-monitor) 3s Hyprland query when
// a moving wallpaper is selected; no always-running process or daemon.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.Services

Singleton {
    id: root
    property var fullscreenIds: []
    function blocked(screen) {
        const monitor = Hyprland.monitorFor(screen);
        return monitor !== null && fullscreenIds.indexOf(monitor.id) >= 0;
    }
    Process {
        id: check
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const clients = JSON.parse(text);
                    const ids = [];
                    for (const c of clients) {
                        // Hyprland reports fullscreen 0 (none) / 1 / 2.
                        if (Number(c.fullscreen) > 0 && ids.indexOf(c.monitor) < 0)
                            ids.push(c.monitor);
                    }
                    root.fullscreenIds = ids;
                } catch (e) { console.warn("WallPower: hyprctl JSON:", e); }
            }
        }
    }
    Timer {
        interval: 3000
        repeat: true
        triggeredOnStart: true
        running: /\.(mp4|webm|mkv)$/i.test(Wall.current)
        onTriggered: { if (!check.running) check.running = true; }
    }
}
