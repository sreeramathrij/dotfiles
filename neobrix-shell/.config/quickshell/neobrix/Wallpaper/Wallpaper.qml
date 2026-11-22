// Wallpaper surface — one background layer per monitor.
//
// Two Image layers crossfade so switching wallpapers doesn't flash the desktop.
// The layer sits below everything (WlrLayer.Background) and takes no input.

import QtQuick
import Quickshell
import Quickshell.Wayland
import QtMultimedia
import qs.Theme
import qs.Services

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: win
        required property var modelData
        screen: modelData

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        exclusionMode: ExclusionMode.Ignore
        // Never intercept clicks meant for the desktop or windows above.
        mask: Region {}
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: "neobrix-wallpaper"
        // A flat theme colour shows through while an image loads, and is the whole
        // wallpaper if none is configured.
        color: Theme.background

        // Which of the two layers is currently on top.
        property bool flip: false
        property string pending: ""

        readonly property string wallpaperPath: Wall.current

        readonly property bool isGif: /\.gif$/i.test(wallpaperPath)

        readonly property bool isVideo: /\.(mp4|webm|mkv)$/i.test(wallpaperPath)

        Image {
            id: layerA
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            smooth: true
            opacity: win.flip ? 0 : 1
            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.durSlow
                }
            }
        }

        Image {
            id: layerB
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            smooth: true
            opacity: win.flip ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.durSlow
                }
            }
        }

        // Animated GIF wallpaper
        AnimatedImage {
            id: animatedWallpaper

            anchors.fill: parent
            visible: win.isGif

            source: win.isGif ? "file://" + win.wallpaperPath : ""

            fillMode: Image.PreserveAspectCrop
            playing: visible
            cache: false
        }

        // Video wallpaper surface
        VideoOutput {
            id: videoWallpaper

            anchors.fill: parent
            z: 2

            visible: win.isVideo

            fillMode: VideoOutput.PreserveAspectCrop
        }

        // Looping video playback

        MediaPlayer {
            id: videoPlayer

            videoOutput: videoWallpaper
            loops: MediaPlayer.Infinite

            onPlaybackStateChanged: {
                console.log("Wallpaper video playback:", playbackState, "Source:", source);
            }

            onMediaStatusChanged: {
                console.log("Wallpaper media status:", mediaStatus);
            }

            onErrorOccurred: (error, errorString) => {
                console.warn("Wallpaper video error:", errorString, "Source:", source);
            }
        }

        // Load into the hidden layer, then flip once it is ready so the crossfade
        // never shows a half-decoded image.
        function show(path) {
            if (path === "")
                return;
            if (/\.(gif|mp4|webm|mkv)$/i.test(path))
                return;
            const url = Qt.resolvedUrl("file://" + path);
            const target = win.flip ? layerA : layerB;
            const shown = win.flip ? layerB : layerA;
            if (shown.source == url)
                return;

            // The flip is driven by onStatusChanged, which only fires when the
            // status actually *changes*. Alternating between two wallpapers —
            // exactly what a dawn/dusk toggle does — eventually leaves the hidden
            // layer already holding the wanted image at status Ready, so
            // reassigning the same source was a no-op, no signal arrived, and the
            // desktop kept showing the other image while Wall.current reported
            // the new one. Swap straight away in that case.
            if (target.source == url && target.status === Image.Ready) {
                win.flip = !win.flip;
                return;
            }
            target.source = url;
        }

        function syncWallpaper() {
            const path = Wall.current;

            const video = /\.(mp4|webm|mkv)$/i.test(path);
            const gif = /\.gif$/i.test(path);

            if (video) {
                console.log("Switching to video:", path);

                videoPlayer.stop();

                videoPlayer.source = Qt.resolvedUrl("file://" + path);

                videoPlayer.play();
            } else {
                videoPlayer.stop();
                videoPlayer.source = "";

                if (!gif && path !== "")
                    win.show(path);
            }
        }

        Connections {
            target: Wall

            function onCurrentChanged() {
                win.syncWallpaper();
            }
        }

        Component.onCompleted: {
            // First paint: no crossfade needed, just load into layer A.
            win.syncWallpaper();
        }

        // Flip when the freshly loaded layer is ready.
        Connections {
            target: layerA
            function onStatusChanged() {
                if (layerA.status === Image.Ready && win.flip)
                    win.flip = false;
            }
        }
        Connections {
            target: layerB
            function onStatusChanged() {
                if (layerB.status === Image.Ready && !win.flip)
                    win.flip = true;
            }
        }
        // BEGIN NB-WALLPOWER-OPTIONAL
        // Pause decoding on the fullscreen window's own monitor only.
        // All other monitors keep animating. Evaluated once per 3s globally.
        readonly property bool wallpaperFullscreenPaused: WallPower.blocked(win.modelData)
        onWallpaperFullscreenPausedChanged: {
            if (!win.isVideo) return;
            if (wallpaperFullscreenPaused) videoPlayer.pause();
            else if (videoPlayer.source.toString() !== "") videoPlayer.play();
        }
        Connections {
            target: videoPlayer
            function onPlaybackStateChanged() {
                // Wallpaper selection may call play() while already fullscreen.
                if (win.isVideo && win.wallpaperFullscreenPaused &&
                        videoPlayer.playbackState === MediaPlayer.PlayingState)
                    videoPlayer.pause();
            }
        }
        // END NB-WALLPOWER-OPTIONAL

        // BEGIN NB-WALLPICKER-V2-TRANSITION
        // Smooth 650 ms dissolve: retain a still of the outgoing wallpaper
        // while the existing video/GIF/static renderer loads the next one.
        // The working playback code above remains untouched.
        Item {
            id: wallTransition
            anchors.fill: parent
            z: 1000
            property string previousPath: ""
            readonly property string cacheDir:
                (Quickshell.env("XDG_CACHE_HOME") || Quickshell.env("HOME") + "/.cache")
                + "/neobrix/wallpaper-transition-posters"
            readonly property string helper:
                Quickshell.env("HOME") + "/.local/share/neobrix-compatible/bin/neobrix-wall-transition-poster"

            function isMoving(path) {
                return /\.(mp4|webm|mkv|gif)$/i.test(path);
            }
            function stillUrl(path) {
                if (path === "") return "";
                const file = isMoving(path)
                    ? cacheDir + "/" + Qt.md5(path) + ".jpg"
                    : path;
                return "file://" + file;
            }
            function preparePoster(path) {
                if (isMoving(path))
                    Quickshell.execDetached([helper, path]);
            }
            function selectionChanged(newPath) {
                if (newPath === previousPath) return;
                // Load the outgoing poster over the incoming video. Using the
                // current still image gives the static wallpaper its full quality.
                if (previousPath !== "" && newPath !== "") {
                    dissolve.stop();
                    revealTimer.stop();
                    outgoing.source = stillUrl(previousPath);
                    outgoing.opacity = 1;
                    revealTimer.restart();
                }
                previousPath = newPath;
                preparePoster(newPath);
            }

            Image {
                id: outgoing
                anchors.fill: parent
                opacity: 0
                source: ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: false
                cache: false
                smooth: true
                visible: opacity > 0
                onStatusChanged: {
                    if (status === Image.Error) {
                        console.warn("NeoBrix transition still unavailable:", source);
                        dissolve.stop();
                        revealTimer.stop();
                        opacity = 0;
                    }
                }
            }
            Timer {
                id: revealTimer
                interval: 300  // let the incoming video produce its first frames
                repeat: false
                onTriggered: dissolve.restart()
            }
            NumberAnimation {
                id: dissolve
                target: outgoing
                property: "opacity"
                from: 1
                to: 0
                duration: 650  // ~39 intermediate blends at a 60 Hz refresh
                easing.type: Easing.InOutQuad
                onFinished: outgoing.source = ""  // free the outgoing still
            }
            Connections {
                target: Wall
                function onCurrentChanged() {
                    wallTransition.selectionChanged(Wall.current);
                }
            }
            Component.onCompleted: {
                previousPath = Wall.current;
                preparePoster(previousPath);
            }
        }
        // END NB-WALLPICKER-V2-TRANSITION
    }
}
