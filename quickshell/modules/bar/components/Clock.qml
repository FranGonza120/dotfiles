import QtQuick 6.10
import QtQuick.Layouts 6.10
import qs.services
import "../../../components/effects"

Item {
    id: root

    property var launcher
    property var controlCenter
    property var sidebar
    property var dashboard
    
    implicitWidth: clockRow.implicitWidth
    implicitHeight: clockRow.implicitHeight
    
    Row {
        id: clockRow
        anchors.centerIn: parent
        spacing: 11
        
        // Compact time display
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            
            // Hours
            Text {
                id: hoursText
                text: Time.format("hh")
                color: Pywal.foreground
                font.pixelSize: 16
                font.weight: Font.Bold
                font.family: "JetBrainsMono Nerd Font"
                font.letterSpacing: 0.3
            }
            
            // Animated colon separator
            Text {
                id: colonSeparator
                text: ":"
                color: Pywal.primary
                font.pixelSize: 16
                font.weight: Font.Bold
                font.family: "JetBrainsMono Nerd Font"
                opacity: 0.4
                
                // Blinks once per second via timer instead of continuous animation
                // to avoid constant GPU repaints
                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: colonSeparator.opacity = colonSeparator.opacity === 1.0 ? 0.4 : 1.0
                }
            }
            
            // Minutes
            Text {
                id: minutesText
                text: Time.format("mm")
                color: Pywal.foreground
                font.pixelSize: 16
                font.weight: Font.Bold
                font.family: "JetBrainsMono Nerd Font"
                font.letterSpacing: 0.3
            }
        }
        
        // Compact date
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Time.compactDate()
            color: Qt.rgba(Pywal.foreground.r, Pywal.foreground.g, Pywal.foreground.b, 0.6)
            font.pixelSize: 16
            font.weight: Font.Medium
            font.family: "JetBrainsMono Nerd Font"
        }
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -8
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.RightButton

        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                if (!root.dashboard)
                    return

                root.dashboard.shouldShow = !root.dashboard.shouldShow
                if (root.dashboard.shouldShow) {
                    if (root.launcher)
                        root.launcher.shouldShow = false
                    if (root.controlCenter)
                        root.controlCenter.shouldShow = false
                    if (root.sidebar)
                        root.sidebar.shouldShow = false
                }
                return
            }
        }
    }
}
