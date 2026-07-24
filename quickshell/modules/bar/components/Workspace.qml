import Quickshell
import QtQuick 6.10
import "../../../config" as QsConfig
import "../../../services" as QsServices
import "../../../components/effects"

// Modern fluid workspace indicator
Rectangle {
    id: root
    
    property int workspaceId: 1
    property bool isActive: false
    property bool isOccupied: false
    
    signal clicked()
    
    readonly property var config: QsConfig.Config
    readonly property var pywal: QsServices.Pywal
    
    // Dynamic sizing with fluid animation
    implicitWidth: {
        if (isActive) return 13
        if (isOccupied) return 13
        return 8
    }
    implicitHeight: {
        if (isActive) return 13
        return 8
    }
    
    // Beautiful gradient-based colors
    color: {
        if (isActive) return pywal.primary
        if (isOccupied) return Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.5)
        return Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.2)
    }
    
    border.width: 0
    radius: height / 2
    
    Behavior on color {
        ColorAnimation {
            duration: Material3Anim.short4
            easing.bezierCurve: Material3Anim.standard
        }
    }
    
    Behavior on opacity {
        NumberAnimation {
            duration: Material3Anim.short4
            easing.bezierCurve: Material3Anim.standard
        }
    }
    
    Behavior on scale {
        NumberAnimation {
            duration: Material3Anim.short2
            easing.bezierCurve: Material3Anim.standard
        }
    }
    
    // Inner glow for active workspace
    Rectangle {
        visible: isActive
        anchors.fill: parent
        anchors.margins: 1
        radius: parent.radius - 1
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.2)
        
        Behavior on opacity {
            NumberAnimation { 
                duration: Material3Anim.short3
                easing.bezierCurve: Material3Anim.standard
            }
        }
    }
    
    // Subtle glow pulse for active workspace
    Rectangle {
        visible: isActive
        anchors.centerIn: parent
        width: parent.width + 5
        height: parent.height + 5
        radius: (height) / 2
        color: "transparent"
        border.width: 2
        border.color: Qt.rgba(pywal.primary.r, pywal.primary.g, pywal.primary.b, 0.15)
        opacity: 0.55
    }
    
    // Workspace number tooltip on hover
    Rectangle {
        id: tooltip
        visible: mouseArea.containsMouse
        anchors.centerIn: parent
        width: 24
        height: 24
        radius: 6
        color: Qt.rgba(pywal.surfaceContainerHighest.r, pywal.surfaceContainerHighest.g, pywal.surfaceContainerHighest.b, 0.95)
        border.width: 1
        border.color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.1)
        
        opacity: mouseArea.containsMouse ? 1 : 0
        scale: mouseArea.containsMouse ? 1 : 0.8
        
        Behavior on opacity {
            NumberAnimation { duration: Material3Anim.short2 }
        }
        
        Behavior on scale {
            NumberAnimation { 
                duration: Material3Anim.short3
                easing.bezierCurve: Material3Anim.emphasizedDecelerate
            }
        }
        
        Text {
            anchors.centerIn: parent
            text: workspaceId
            color: pywal.foreground
            font.pixelSize: 16
            font.weight: Font.Bold
            font.family: "JetBrainsMono Nerd Font"
        }
    }
    
    // Mouse interaction
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        anchors.margins: -5
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: root.clicked()
        
        onPressed: {
            root.scale = 0.85
        }
        
        onReleased: {
            root.scale = 1.0
        }
        
        onEntered: {
            if (!isActive) {
                root.scale = 1.2
            }
        }
        
        onExited: {
            root.scale = 1.0
        }
    }
    
    scale: 1.0
}
