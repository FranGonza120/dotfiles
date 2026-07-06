import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import Quickshell.Io
import qs.services
import "../../../components"
import "../../../components/effects"

// Compact Music Widget - Fixed buttons, proper text reset
Item {
    id: root
    
    property var barWindow
    property var mediaPopup
    property bool dockMode: false

    readonly property int rowHeight: root.dockMode ? 64 : 22
    readonly property int titleWidth: root.dockMode ? 90 : 80
    readonly property int recordSize: root.dockMode ? 52 : 20
    readonly property int vinylSize: root.dockMode ? 44 : 16
    readonly property int controlSize: root.dockMode ? 44 : 20
    readonly property int playSize: root.dockMode ? 52 : 24
    readonly property int progressWidth: root.dockMode ? 48 : 35
    readonly property int progressHeight: root.dockMode ? 8 : 4
    readonly property int titleFontSize: root.dockMode ? 18 : 16
    readonly property int iconFontSize: root.dockMode ? 25 : 16
    readonly property int playIconFontSize: root.dockMode ? 28 : 16
    
    // Always show - either player content or "No media" text
    // Use fixed width for no media state to avoid circular dependency
    implicitWidth: hasPlayer ? contentRow.implicitWidth : (root.dockMode ? 170 : 70)
    implicitHeight: root.rowHeight
    visible: true
    
    readonly property var player: Players.active
    readonly property bool hasPlayer: player !== null
    readonly property bool isPlaying: player?.isPlaying ?? false
    property real progress: 0
    property real duration: player?.length ?? 1
    property real progressPercent: duration > 0 ? progress / duration : 0
    
    property bool isHovered: contentMouse.containsMouse || noMediaMouse.containsMouse
    
    // Poll position via playerctl for live progress updates
    Timer {
        interval: 1000
        running: hasPlayer && isPlaying
        repeat: true
        onTriggered: posPollProc.running = true
    }
    
    Process {
        id: posPollProc
        command: ["playerctl", "position"]
        stdout: StdioCollector {
            onStreamFinished: {
                var val = parseFloat(text.trim())
                if (!isNaN(val) && val >= 0)
                    root.progress = val * 1000000  // playerctl returns seconds, convert to microseconds
            }
        }
    }
    
    Process {
        id: lenPollProc
        command: ["playerctl", "metadata", "mpris:length"]
        stdout: StdioCollector {
            onStreamFinished: {
                var val = parseFloat(text.trim())
                if (!isNaN(val) && val > 0)
                    root.duration = val  // mpris:length is in microseconds
            }
        }
    }
    
    onPlayerChanged: lenPollProc.running = true
    
    onIsPlayingChanged: {
        if (isPlaying) {
            posPollProc.running = true
            lenPollProc.running = true
        } else {
            marqueeAnim.stop()
            titleText.x = titleText.needsScroll ? 0 : (root.titleWidth - titleText.implicitWidth) / 2
        }
    }
    
    // No media placeholder
    RowLayout {
        id: noMediaRow
        anchors.centerIn: parent
        spacing: root.dockMode ? 14 : 6
        visible: !hasPlayer
        opacity: !hasPlayer ? 1 : 0
        
        Behavior on opacity { NumberAnimation { duration: 200 } }
        
        Text {
            text: "󰎇"
            font.family: "Material Design Icons"
            font.pixelSize: root.iconFontSize
            color: Qt.rgba(Pywal.foreground.r, Pywal.foreground.g, Pywal.foreground.b, 0.4)
            Layout.alignment: Qt.AlignVCenter
        }
        
        Text {
            text: "No media"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: root.titleFontSize
            font.weight: Font.Medium
            color: Qt.rgba(Pywal.foreground.r, Pywal.foreground.g, Pywal.foreground.b, 0.4)
            Layout.alignment: Qt.AlignVCenter
        }
    }
    
    // Mouse area for no media state (outside layout)
    MouseArea {
        id: noMediaMouse
        anchors.fill: parent
        visible: !hasPlayer
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }
    
    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: root.dockMode ? 7 : 6
        visible: hasPlayer
        opacity: hasPlayer ? 1 : 0
        
        Behavior on opacity { NumberAnimation { duration: 200 } }
        
        // Vinyl Record with glow
        Item {
            Layout.preferredWidth: root.recordSize
            Layout.preferredHeight: root.recordSize
            Layout.alignment: Qt.AlignVCenter
            
            // Glow when playing
            Rectangle {
                visible: root.isPlaying
                anchors.centerIn: parent
                width: root.recordSize + 2
                height: root.recordSize + 2
                radius: width / 2
                color: "transparent"
                border.width: 1
                border.color: Qt.rgba(Pywal.primary.r, Pywal.primary.g, Pywal.primary.b, 0.3)
                
                SequentialAnimation on opacity {
                    running: root.isPlaying
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.3; duration: 1000 }
                    NumberAnimation { to: 1.0; duration: 1000 }
                }
            }
            
            Rectangle {
                id: vinyl
                anchors.centerIn: parent
                width: root.vinylSize
                height: root.vinylSize
                radius: width / 2
                color: Pywal.surfaceContainerLow
                
                rotation: 0
                
                RotationAnimation on rotation {
                    running: root.isPlaying
                    from: vinyl.rotation
                    to: vinyl.rotation + 360
                    duration: 2500
                    loops: Animation.Infinite
                }
                
                // Groove rings
                Repeater {
                    model: 2
                    Rectangle {
                        anchors.centerIn: parent
                        width: (root.vinylSize - 6) - index * (root.dockMode ? 6 : 3)
                        height: width
                        radius: width / 2
                        color: "transparent"
                        border.width: 0.5
                        border.color: Qt.rgba(1, 1, 1, 0.08)
                    }
                }
                
                // Center label
                Rectangle {
                    anchors.centerIn: parent
                    width: root.dockMode ? 10 : 5
                    height: width
                    radius: width / 2
                    color: Pywal.primary
                    
                    Rectangle {
                        anchors.centerIn: parent
                        width: root.dockMode ? 4 : 2
                        height: width
                        radius: width / 2
                        color: Qt.rgba(0, 0, 0, 0.5)
                    }
                }
            }
        }
        
        // Track Title - Marquee with proper reset
        Item {
            Layout.preferredWidth: root.titleWidth
            Layout.preferredHeight: parent.height
            Layout.alignment: Qt.AlignVCenter
            clip: true
            
            MouseArea {
                id: contentMouse
                anchors.fill: parent
                hoverEnabled: true
            }
            
            Text {
                id: titleText
                anchors.verticalCenter: parent.verticalCenter
                
                text: root.player?.trackTitle ?? "Unknown"
                color: Pywal.foreground
                font.pixelSize: root.titleFontSize
                font.weight: Font.Medium
                
                property bool needsScroll: implicitWidth > root.titleWidth
                
                x: needsScroll ? 0 : (root.titleWidth - implicitWidth) / 2
                
                Behavior on x {
                    enabled: !marqueeAnim.running
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }
                
                SequentialAnimation {
                    id: marqueeAnim
                    running: titleText.needsScroll && root.isPlaying
                    loops: Animation.Infinite
                    
                    PauseAnimation { duration: 2000 }
                    NumberAnimation {
                        target: titleText
                        property: "x"
                        to: -(titleText.implicitWidth + 20)
                        duration: titleText.implicitWidth * 30
                        easing.type: Easing.Linear
                    }
                    PropertyAction { 
                        target: titleText
                        property: "x"
                        value: root.titleWidth
                    }
                    NumberAnimation {
                        target: titleText
                        property: "x"
                        to: 0
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
        
        // Stylish divider
        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: root.dockMode ? 36 : 12
            Layout.alignment: Qt.AlignVCenter
            radius: 0.5
            color: Qt.rgba(Pywal.foreground.r, Pywal.foreground.g, Pywal.foreground.b, 0.18)
        }
        
        // Controls - Fixed with proper click handling
        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: root.dockMode ? 4 : 2
            
            // Previous button
            Rectangle {
                Layout.preferredWidth: root.controlSize
                Layout.preferredHeight: root.controlSize
                radius: root.controlSize / 2
                color: prevArea.containsMouse ? Qt.rgba(Pywal.foreground.r, Pywal.foreground.g, Pywal.foreground.b, 0.15) : "transparent"
                
                Behavior on color { ColorAnimation { duration: 100 } }
                Behavior on scale { NumberAnimation { duration: 80 } }
                scale: prevArea.pressed ? 0.9 : 1.0
                
                Text {
                    anchors.centerIn: parent
                    text: "󰒮"
                    font.family: "Material Design Icons"
                    font.pixelSize: root.iconFontSize
                    color: prevArea.containsMouse ? Pywal.primary : Pywal.foreground
                    
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
                
                MouseArea {
                    id: prevArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        Players.previous()
                    }
                }
            }
            
            // Play/Pause button - Main action
            Rectangle {
                Layout.preferredWidth: root.playSize
                Layout.preferredHeight: root.playSize
                radius: root.playSize / 2
                color: playArea.containsMouse ? Qt.lighter(Pywal.primary, 1.08) : Pywal.primary
                
                Behavior on scale { NumberAnimation { duration: 80 } }
                scale: playArea.pressed ? 0.85 : (playArea.containsMouse ? 1.05 : 1.0)
                
                // Glow effect
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 4
                    height: parent.height + 4
                    radius: width / 2
                    color: "transparent"
                    border.width: 2
                    border.color: Qt.rgba(Pywal.primary.r, Pywal.primary.g, Pywal.primary.b, playArea.containsMouse ? 0.3 : 0)
                    z: -1
                    
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                }
                
                Text {
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: root.isPlaying ? 0 : 1
                    text: root.isPlaying ? "󰏤" : "󰐊"
                    font.family: "Material Design Icons"
                    font.pixelSize: root.playIconFontSize
                    color: Pywal.onPrimary
                }
                
                MouseArea {
                    id: playArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        Players.togglePlaying()
                    }
                }
            }
            
            // Next button
            Rectangle {
                Layout.preferredWidth: root.controlSize
                Layout.preferredHeight: root.controlSize
                radius: root.controlSize / 2
                color: nextArea.containsMouse ? Qt.rgba(Pywal.foreground.r, Pywal.foreground.g, Pywal.foreground.b, 0.15) : "transparent"
                
                Behavior on color { ColorAnimation { duration: 100 } }
                Behavior on scale { NumberAnimation { duration: 80 } }
                scale: nextArea.pressed ? 0.9 : 1.0
                
                Text {
                    anchors.centerIn: parent
                    text: "󰒭"
                    font.family: "Material Design Icons"
                    font.pixelSize: root.iconFontSize
                    color: nextArea.containsMouse ? Pywal.primary : Pywal.foreground
                    
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
                
                MouseArea {
                    id: nextArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        Players.next()
                    }
                }
            }
        }
        
        // Beautiful progress bar
        Item {
            Layout.preferredWidth: root.progressWidth
            Layout.preferredHeight: root.progressHeight
            Layout.alignment: Qt.AlignVCenter
            
            Rectangle {
                anchors.fill: parent
                radius: root.progressHeight / 2
                color: Qt.rgba(Pywal.foreground.r, Pywal.foreground.g, Pywal.foreground.b, 0.12)
                
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * root.progressPercent
                    radius: root.progressHeight / 2
                    color: Pywal.primary
                    
                    Behavior on width {
                        NumberAnimation { duration: 200 }
                    }
                    
                    // Playhead dot
                    Rectangle {
                        visible: root.isPlaying
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: root.dockMode ? 12 : 6
                        height: width
                        radius: width / 2
                        color: Pywal.onPrimary
                        
                        SequentialAnimation on scale {
                            running: root.isPlaying
                            loops: Animation.Infinite
                            NumberAnimation { to: 1.2; duration: 600 }
                            NumberAnimation { to: 1.0; duration: 600 }
                        }
                    }
                }
            }
        }
    }
}
