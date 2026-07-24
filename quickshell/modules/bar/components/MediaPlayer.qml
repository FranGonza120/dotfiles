import QtQuick 6.10
import QtQuick.Layouts 6.10
import qs.services
import "../../../components"
import "../../../components/effects"

// Compact Music Widget - Fixed buttons, proper text reset
Item {
    id: root
    
    property bool dockMode: false

    readonly property int rowHeight: root.dockMode ? 64 : 22
    readonly property int titleWidth: root.dockMode ? 90 : 80
    readonly property int recordSize: root.dockMode ? 52 : 20
    readonly property int vinylSize: root.dockMode ? 44 : 16
    readonly property int controlSize: root.dockMode ? 44 : 20
    readonly property int playSize: root.dockMode ? 52 : 24
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
    
    property bool isHovered: contentMouse.containsMouse || noMediaMouse.containsMouse
    
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
        anchors.fill: parent
        anchors.margins: root.dockMode ? 6 : 0
        spacing: root.dockMode ? 10 : 6
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
                opacity: 0.7
            }
            
            Rectangle {
                id: vinyl
                anchors.centerIn: parent
                width: root.vinylSize
                height: root.vinylSize
                radius: width / 2
                color: Pywal.surfaceContainerLow

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
            Layout.fillWidth: true
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
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: root.titleFontSize
                font.weight: Font.Medium
                width: root.titleWidth
                elide: Text.ElideRight
            }
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
    }
}
