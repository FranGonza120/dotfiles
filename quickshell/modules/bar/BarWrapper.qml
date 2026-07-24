import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick 6.10
import "../../config" as QsConfig
import "../../services" as QsServices

Scope {
    readonly property var config: QsConfig.Config
    readonly property string launcherCommandPath: "/tmp/quickshell-launcher-mode"
    property bool launcherCommandInitialized: false
    property var activeLauncherLoader: null

    function openLauncherLoader(loader, mode) {
        if (!loader)
            return

        if (launcherUnloadTimer.running && activeLauncherLoader === loader)
            launcherUnloadTimer.stop()

        loader.pendingMode = mode
        activeLauncherLoader = loader
        if (loader.item) {
            loader.item.launcherMode = mode
            loader.item.openLauncher()
            return
        }

        loader.active = true
    }

    function closeLaunchers() {
        launcherUnloadTimer.stop()
        const launchers = [appLauncherLoader, fileLauncherLoader, wallpaperLauncherLoader]
        for (let i = 0; i < launchers.length; i++) {
            const loader = launchers[i]
            loader.pendingMode = ""
            if (loader.item)
                loader.item.closeLauncher(true)
            loader.active = false
        }
        activeLauncherLoader = null
    }

    function openLauncher(mode) {
        closeLaunchers()
        openLauncherLoader(mode === "files"
            ? fileLauncherLoader
            : mode === "wallpapers"
                ? wallpaperLauncherLoader
                : appLauncherLoader, mode)
    }
    
    // Popup windows removed — popups are now hosted inline inside the bar PanelWindow
    
    // Control Center window
    Loader {
        id: controlCenterLoader
        active: false
        source: "../controlcenter/ControlCenterWindow.qml"
        asynchronous: true
        
        property var controlCenter: item
        property bool pendingShow: false
        
        onStatusChanged: {
            QsServices.Logger.debug(
                "BarWrapper",
                `Control Center loader status: ${status === Loader.Ready ? "READY" : status === Loader.Loading ? "LOADING" : status === Loader.Error ? "ERROR" : "NULL"}`
            )
            if (status === Loader.Error) {
                QsServices.Logger.error("BarWrapper", "Control Center failed to load")
            }
            if (status === Loader.Ready) {
                QsServices.Logger.debug("BarWrapper", `Control Center loaded, item: ${item ? "EXISTS" : "NULL"}`)
                if (pendingShow && item) {
                    unloadControlCenterTimer.stop()
                    item.shouldShow = true
                    pendingShow = false
                }
            }
        }
    }

    Timer {
        id: unloadControlCenterTimer
        interval: 500
        repeat: false
        onTriggered: {
            if (controlCenterLoader.active && !controlCenterLoader.pendingShow && controlCenterLoader.item && !controlCenterLoader.item.shouldShow)
                controlCenterLoader.active = false
        }
    }

    Connections {
        target: controlCenterLoader.item

        function onShouldShowChanged() {
            if (!controlCenterLoader.item)
                return

            if (controlCenterLoader.item.shouldShow) {
                unloadControlCenterTimer.stop()
            } else if (controlCenterLoader.active) {
                unloadControlCenterTimer.restart()
            }
        }
    }

    Loader {
        id: appLauncherLoader
        active: false
        source: "../launcher/LauncherWindow.qml"
        asynchronous: true
        property string pendingMode: ""

        onStatusChanged: {
            if (status === Loader.Ready && item) {
                item.launcherMode = pendingMode || "apps"
                if (pendingMode)
                    item.openLauncher()
            }
        }
    }

    Loader {
        id: fileLauncherLoader
        active: false
        source: "../launcher/LauncherWindow.qml"
        asynchronous: true
        property string pendingMode: ""

        onStatusChanged: {
            if (status === Loader.Ready && item) {
                item.launcherMode = pendingMode || "files"
                if (pendingMode)
                    item.openLauncher()
            }
        }
    }

    Loader {
        id: wallpaperLauncherLoader
        active: false
        source: "../launcher/LauncherWindow.qml"
        asynchronous: true
        property string pendingMode: ""

        onStatusChanged: {
            if (status === Loader.Ready && item) {
                item.launcherMode = pendingMode || "wallpapers"
                if (pendingMode)
                    item.openLauncher()
            }
        }
    }

    Timer {
        id: launcherUnloadTimer
        interval: 350
        repeat: false
        onTriggered: {
            const loader = activeLauncherLoader
            if (loader && loader.active && !loader.pendingMode && loader.item && !loader.item.shouldShow) {
                loader.active = false
                if (activeLauncherLoader === loader)
                    activeLauncherLoader = null
            }
        }
    }

    Connections {
        target: activeLauncherLoader ? activeLauncherLoader.item : null
        function onShouldShowChanged() {
            const loader = activeLauncherLoader
            if (!loader || !loader.item)
                return

            if (loader.item.shouldShow) {
                loader.pendingMode = ""
                launcherUnloadTimer.stop()
            } else if (loader.active) {
                launcherUnloadTimer.restart()
            }
        }
    }

    FileView {
        id: launcherCommandFile
        path: launcherCommandPath
        watchChanges: true

        onLoaded: {
            if (!launcherCommandInitialized) {
                launcherCommandInitialized = true
                return
            }
            const mode = text().trim()
            if (mode === "apps" || mode === "files" || mode === "wallpapers")
                openLauncher(mode)
        }

        onFileChanged: launcherCommandFile.reload()
    }
    
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: window
            
            property var modelData
            
            screen: modelData
            anchors {
                top: true
                left: true
                right: true
            }
            
            // Fixed exclusive zone: only the bar strip reserves space
            exclusiveZone: config.bar.height
            
            // Dynamic height: bar + inline popup area
            implicitHeight: config.bar.height + (barLoader.item?.popupAreaHeight ?? 0)
            color: "transparent"
            
            // Allow keyboard focus when a popup is open
            WlrLayershell.keyboardFocus: (barLoader.item?.hasPopup ?? false) ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
            
            // Bar content (fills window: bar strip at top, popup host below)
            Loader {
                id: barLoader
                anchors.fill: parent
                source: "Bar.qml"
                
                onStatusChanged: {
                    if (status === Loader.Ready) {
                        item.screen = Qt.binding(() => modelData)
                        item.controlCenterWindowLoader = Qt.binding(() => controlCenterLoader)
                    }
                }
            }
        }
    }
}
