import Quickshell
import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Effects
import "components" as BarComponents
import "../../components"
import "../../components/effects"
import "../../config" as QsConfig
import "../../services" as QsServices

Item {
    id: root
    
    property var screen
    property var barWindow
    property var controlCenter
    property var launcher
    property var sidebar
    property var dashboard
    
    // ═══ Inline Popup State ═══
    property string activePopup: ""  // "", "bluetooth", "network"
    readonly property bool hasPopup: activePopup !== ""
    readonly property real popupAreaHeight: hasPopup ? popupHost.height : 0
    
    function togglePopup(name: string) {
        if (activePopup === name) {
            activePopup = ""
        } else {
            activePopup = name
        }
    }
    function closePopup() {
        activePopup = ""
    }

    function popupAnchorTarget() {
        if (activePopup === "network" || activePopup === "bluetooth") return connectivityPill
        if (activePopup === "battery") return powerPill
        return rightPills
    }
    
    readonly property var config: QsConfig.Config
    readonly property var appearance: QsConfig.AppearanceConfig
    readonly property var pywal: QsServices.Pywal
    
    // ═══════════════════════════════════════════════════════════════════════
    // MINIMAL AESTHETIC BAR
    // Clean, professional, beautiful - inspired by modern Linux rice
    // ═══════════════════════════════════════════════════════════════════════
    
    // Main bar container with floating effect — pinned to top bar strip
    Item {
        id: barContainer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        anchors.topMargin: 2
        height: config.bar.height - 4
        
        // ═══════════════════════════════════════════════════════════════
        // LEFT MODULE - Workspaces
        // ═══════════════════════════════════════════════════════════════
        AuroraSurface {
            id: leftModule
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            height: 42
            width: leftContent.implicitWidth + 24
            
            radius: 24
            color: pywal.surfaceContainerHigh
            strokeColor: pywal.outlineVariant
            borderWidth: 0
            accentColor: pywal.primary
            elevation: 3
            
            // Smooth transitions
            Behavior on color {
                ColorAnimation { duration: 400; easing.type: Easing.OutCubic }
            }
            
            Behavior on width {
                NumberAnimation { duration: 350; easing.bezierCurve: [0.34, 1.56, 0.64, 1] }
            }
            
            RowLayout {
                id: leftContent
                anchors.centerIn: parent
                spacing: 13
                
                // Workspaces
                Loader {
                    id: workspacesLoader
                    Layout.alignment: Qt.AlignVCenter
                    asynchronous: true
                    source: "components/Workspaces.qml"
                    
                    Binding {
                        target: workspacesLoader.item
                        property: "screen"
                        value: root.screen
                        when: workspacesLoader.status === Loader.Ready && root.screen !== undefined
                        restoreMode: Binding.RestoreBinding
                    }
                }
            }
        }
        
        // ═══════════════════════════════════════════════════════════════
        // RIGHT SIDE - Three Separate Pills
        // ═══════════════════════════════════════════════════════════════
        Row {
            id: rightPills
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8
            
            // ═══ PILL 1: Volume + Battery + Clock ═══
            AuroraSurface {
                id: powerPill
                height: 42
                width: powerContent.implicitWidth + 24
                radius: 24
                color: pywal.surfaceContainerHigh
                strokeColor: pywal.outlineVariant
                borderWidth: 0
                accentColor: pywal.primary
                elevation: 3
                
                Behavior on color {
                    ColorAnimation { duration: 300 }
                }
                Behavior on width {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }
                
                Row {
                    id: powerContent
                    anchors.centerIn: parent
                    spacing: 9
                    
                    Loader {
                        id: volumeLoader
                        anchors.verticalCenter: parent.verticalCenter
                        asynchronous: true
                        source: "components/Volume.qml"
                        
                        Binding {
                            target: volumeLoader.item
                            property: "barWindow"
                            value: root.barWindow
                            when: volumeLoader.status === Loader.Ready && root.barWindow !== undefined
                            restoreMode: Binding.RestoreBinding
                        }
                    }
                    
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 1
                        height: 16
                        radius: 1
                        color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.12)
                    }
                    
                    Loader {
                        id: batteryLoader
                        anchors.verticalCenter: parent.verticalCenter
                        asynchronous: true
                        source: "components/Battery.qml"
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 1
                        height: 16
                        radius: 1
                        color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.12)
                    }

                    Loader {
                        id: clockLoader
                        anchors.verticalCenter: parent.verticalCenter
                        asynchronous: true
                        source: "components/Clock.qml"

                        Binding {
                            target: clockLoader.item
                            property: "launcher"
                            value: root.launcher
                            when: clockLoader.status === Loader.Ready && root.launcher !== undefined
                            restoreMode: Binding.RestoreBinding
                        }

                        Binding {
                            target: clockLoader.item
                            property: "controlCenter"
                            value: root.controlCenter
                            when: clockLoader.status === Loader.Ready && root.controlCenter !== undefined
                            restoreMode: Binding.RestoreBinding
                        }

                        Binding {
                            target: clockLoader.item
                            property: "sidebar"
                            value: root.sidebar
                            when: clockLoader.status === Loader.Ready && root.sidebar !== undefined
                            restoreMode: Binding.RestoreBinding
                        }
                        
                        Binding {
                            target: clockLoader.item
                            property: "dashboard"
                            value: root.dashboard
                            when: clockLoader.status === Loader.Ready && root.dashboard !== undefined
                            restoreMode: Binding.RestoreBinding
                        }
                    }
                }
            }
            
            // ═══ PILL 2: Network + Bluetooth (Connectivity) ═══
            AuroraSurface {
                id: connectivityPill
                height: 42
                width: connectivityContent.implicitWidth + 24
                radius: 24
                color: pywal.surfaceContainerHigh
                strokeColor: pywal.outlineVariant
                borderWidth: 0
                accentColor: pywal.info
                elevation: 3
                
                Behavior on color {
                    ColorAnimation { duration: 300 }
                }
                Behavior on width {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }
                
                Row {
                    id: connectivityContent
                    anchors.centerIn: parent
                    spacing: 11
                    
                    Loader {
                        id: networkLoader
                        anchors.verticalCenter: parent.verticalCenter
                        asynchronous: true
                        source: "components/Network.qml"
                        
                        Binding {
                            target: networkLoader.item
                            property: "barWindow"
                            value: root.barWindow
                            when: networkLoader.status === Loader.Ready && root.barWindow !== undefined
                            restoreMode: Binding.RestoreBinding
                        }
                        
                        Binding {
                            target: networkLoader.item
                            property: "bar"
                            value: root
                            when: networkLoader.status === Loader.Ready
                            restoreMode: Binding.RestoreBinding
                        }
                    }
                    
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 1
                        height: 16
                        radius: 1
                        color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.12)
                    }
                    
                    Loader {
                        id: bluetoothLoader
                        anchors.verticalCenter: parent.verticalCenter
                        asynchronous: true
                        source: "components/Bluetooth.qml"
                        
                        Binding {
                            target: bluetoothLoader.item
                            property: "barWindow"
                            value: root.barWindow
                            when: bluetoothLoader.status === Loader.Ready && root.barWindow !== undefined
                            restoreMode: Binding.RestoreBinding
                        }
                        
                        Binding {
                            target: bluetoothLoader.item
                            property: "bar"
                            value: root
                            when: bluetoothLoader.status === Loader.Ready
                            restoreMode: Binding.RestoreBinding
                        }
                    }
                }
            }
            
            // ═══ PILL 3: Control Center ═══
            AuroraSurface {
                id: controlPill
                height: 42
                width: controlContent.implicitWidth + 24
                radius: 24
                color: pywal.surfaceContainerHigh
                strokeColor: pywal.outlineVariant
                borderWidth: 0
                accentColor: pywal.primary
                elevation: 3
                
                Behavior on color {
                    ColorAnimation { duration: 300 }
                }
                Behavior on width {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }
                
                Row {
                    id: controlContent
                    anchors.centerIn: parent
                    spacing: 0

                    Loader {
                        id: controlCenterLoader
                        anchors.verticalCenter: parent.verticalCenter
                        asynchronous: true
                        source: "components/ControlCenterToggle.qml"
                        
                        Binding {
                            target: controlCenterLoader.item
                            property: "controlCenter"
                            value: root.controlCenter
                            when: controlCenterLoader.status === Loader.Ready && root.controlCenter !== undefined
                            restoreMode: Binding.RestoreBinding
                        }
                    }
                }
            }
        }
    }
    
    // ═══════════════════════════════════════════════════════════════════════
    // INLINE POPUP HOST — popups expand below the bar within the same window
    // ═══════════════════════════════════════════════════════════════════════
    Item {
        id: popupHost
        anchors.top: barContainer.bottom
        anchors.topMargin: 4
        anchors.left: parent.left
        anchors.right: parent.right
        height: hasPopup ? popupContentWrapper.height + 12 : 0
        clip: true

        // Match Control Center behavior: close after leaving popup focus area
        property bool mouseHasEntered: false
        property bool mouseInside: popupHoverHandler.hovered

        onVisibleChanged: {
            if (!visible) {
                mouseHasEntered = false
                popupCloseTimer.stop()
            }
        }

        Connections {
            target: root
            function onHasPopupChanged() {
                if (root.hasPopup) {
                    popupHost.mouseHasEntered = false
                    popupCloseTimer.stop()
                } else {
                    popupCloseTimer.stop()
                }
            }
        }

        Timer {
            id: popupCloseTimer
            interval: 400
            onTriggered: {
                if (!popupHost.mouseInside && popupHost.mouseHasEntered && root.hasPopup) {
                    root.closePopup()
                }
            }
        }
        
        Behavior on height {
            NumberAnimation {
                duration: 280
                easing.type: Easing.OutCubic
            }
        }
        
        // Click-outside scrim to dismiss popup
        MouseArea {
            anchors.fill: parent
            visible: hasPopup
            onClicked: root.closePopup()
        }
        
        // Popup content container — positioned below the triggering pill
        Item {
            id: popupContentWrapper
            y: 4
            x: {
                // Center popup under its trigger and clamp to host bounds
                const w = width
                const hostPadding = 12
                const anchor = root.popupAnchorTarget()

                if (anchor) {
                    const centerInHost = anchor.mapToItem(popupHost, anchor.width / 2, anchor.height).x
                    return Math.max(hostPadding, Math.min(popupHost.width - w - hostPadding, centerInHost - (w / 2)))
                }

                return Math.max(hostPadding, popupHost.width - w - hostPadding)
            }
            width: activePopup === "network" ? 340 : 320
            height: {
                if (btPanelLoader.active && btPanelLoader.item)
                    return btPanelLoader.item.implicitHeight
                if (netPanelLoader.active && netPanelLoader.item)
                    return netPanelLoader.item.implicitHeight
                return 0
            }
            
            // Entry animation
            scale: hasPopup ? 1.0 : 0.92
            opacity: hasPopup ? 1 : 0
            transformOrigin: Item.TopRight
            
            Behavior on scale {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.1
                }
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            HoverHandler {
                id: popupHoverHandler
                onHoveredChanged: {
                    if (hovered) {
                        popupHost.mouseHasEntered = true
                        popupCloseTimer.stop()
                    } else if (popupHost.mouseHasEntered && root.hasPopup) {
                        popupCloseTimer.restart()
                    }
                }
            }
            
            // Bluetooth Panel
            Loader {
                id: btPanelLoader
                anchors.fill: parent
                active: root.activePopup === "bluetooth"
                source: "components/BluetoothPanel.qml"
                
                onLoaded: {
                    item.shouldShow = true
                    item.forceActiveFocus()
                }
                
                Connections {
                    target: btPanelLoader.item
                    function onCloseRequested() { root.closePopup() }
                }
            }
            
            // Network Panel
            Loader {
                id: netPanelLoader
                anchors.fill: parent
                active: root.activePopup === "network"
                source: "components/NetworkPanel.qml"
                
                onLoaded: {
                    item.shouldShow = true
                    item.forceActiveFocus()
                }
                
                Connections {
                    target: netPanelLoader.item
                    function onCloseRequested() { root.closePopup() }
                }
            }
        }
    }
}
