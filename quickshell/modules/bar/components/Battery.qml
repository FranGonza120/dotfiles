import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import Quickshell.Services.UPower
import "../../../services" as QsServices
import "../../../components/effects"

// Samsung-style animated battery - Matches the reference image
Item {
    id: root
    
    implicitWidth: batteryContainer.width
    implicitHeight: 32
    
    readonly property var battery: UPower.displayDevice
    readonly property var pywal: QsServices.Pywal
    readonly property real percentage: battery?.percentage ?? 0
    readonly property int batteryLevel: Math.round(percentage * 100)
    readonly property bool isCharging: battery?.state === UPowerDevice.Charging
    readonly property bool isFullyCharged: battery?.state === UPowerDevice.FullyCharged
    readonly property bool isPluggedIn: isCharging || isFullyCharged
    readonly property bool isWarning: batteryLevel <= 25 && batteryLevel > 15
    readonly property bool isLow: batteryLevel <= 15
    readonly property bool isCritical: isLow && !isPluggedIn
    
    // Track state changes for animations
    property bool wasPluggedIn: false
    property bool showExpandedMode: false
    property bool justPluggedIn: false
    
    // Detect plug-in event
    onIsPluggedInChanged: {
        if (isPluggedIn && !wasPluggedIn) {
            // Just plugged in - trigger expansion animation
            justPluggedIn = true
            showExpandedMode = true
            liquidFillAnim.restart()
            expandTimer.restart()
        }
        wasPluggedIn = isPluggedIn
    }
    
    // Timer to collapse back after showing liquid fill
    Timer {
        id: expandTimer
        interval: 4000
        onTriggered: {
            showExpandedMode = false
            justPluggedIn = false
        }
    }
    
    // Colors
    readonly property color normalColor: {
        if (isLow) return pywal.error
        if (isWarning) return pywal.warning
        if (batteryLevel >= 60) return Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.7)
        return Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.6)
    }
    
    readonly property color chargingColor: pywal.success
    readonly property color liquidColor: Qt.lighter(pywal.success, 1.2)
    readonly property color compactBatteryColor: {
        if (showExpandedMode || justPluggedIn) return chargingColor
        if (isPluggedIn && (isLow || isWarning)) return normalColor
        if (isPluggedIn) return chargingColor
        return normalColor
    }
    
    // Main container
    Item {
        id: batteryContainer
        anchors.centerIn: parent
        width: showExpandedMode ? expandedPill.width : normalBattery.width
        height: 32
        
        Behavior on width {
            NumberAnimation { 
                duration: 450
                easing.type: Easing.OutBack
                easing.overshoot: 1.1
            }
        }
        
        // ═══════════════════════════════════════════════════════════════
        // STATE 1 & 3: Normal / Charging compact view
        // ═══════════════════════════════════════════════════════════════
        Row {
            id: normalBattery
            anchors.centerIn: parent
            spacing: 5
            visible: !showExpandedMode
            opacity: showExpandedMode ? 0 : 1
            
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
            
            // Battery icon
            Item {
                width: 29
                height: 19
                anchors.verticalCenter: parent.verticalCenter
                
                // Battery body
                Rectangle {
                    id: batteryBody
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 27
                    height: 16
                    radius: 4
                    color: "transparent"
                    border.width: 1.5
                    border.color: compactBatteryColor
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 300 }
                    }
                    
                    // Fill level
                    Rectangle {
                        id: fillRect
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.margins: 3
                        width: Math.max(0, (parent.width - 6) * root.percentage)
                        radius: 2
                        color: compactBatteryColor
                        
                        Behavior on width {
                            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
                        }
                        
                        // Charging shimmer
                        Rectangle {
                            id: chargeShimmer
                            visible: false
                            anchors.fill: parent
                            radius: parent.radius
                            color: Qt.rgba(1, 1, 1, 0.12)
                            opacity: 0
                            
                            property real shimmerPos: 0
                            x: (parent.width + width) * shimmerPos - width
                            
                        }
                    }
                }
                
                // Terminal nub
                Rectangle {
                    anchors.left: batteryBody.right
                    anchors.leftMargin: -1
                    anchors.verticalCenter: parent.verticalCenter
                    width: 4
                    height: 7
                    radius: 2
                    color: compactBatteryColor
                    
                    Behavior on color {
                        ColorAnimation { duration: 300 }
                    }
                }
                
                // Charging bolt icon
                Text {
                    visible: isPluggedIn && !showExpandedMode
                    anchors.centerIn: batteryBody
                    text: "󱐋"
                    font.family: "Material Design Icons"
                    font.pixelSize: 12
                    color: batteryLevel > 50 ? pywal.background : pywal.foreground
                    opacity: 0.9
                }
            }
            
            // Percentage text
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: batteryLevel + "%"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
                font.weight: (isWarning || isLow) ? Font.Bold : Font.Medium
                color: compactBatteryColor
                
                Behavior on color {
                    ColorAnimation { duration: 300 }
                }
            }
        }
        
        // ═══════════════════════════════════════════════════════════════
        // STATE 2: Just plugged in - Samsung-style expanded pill
        // ═══════════════════════════════════════════════════════════════
        Rectangle {
            id: expandedPill
            anchors.centerIn: parent
            width: 69
            height: 27
            radius: 14
            visible: showExpandedMode
            opacity: showExpandedMode ? 1 : 0
            color: pywal.surfaceDim
            border.width: 1.5
            border.color: chargingColor
            
            Behavior on opacity {
                NumberAnimation { duration: 250 }
            }
            
            // Liquid fill inside
            Rectangle {
                id: liquidFillBg
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 2
                width: 0
                radius: parent.radius - 2
                color: chargingColor
                
                // Liquid fill animation
                SequentialAnimation {
                    id: liquidFillAnim
                    
                    NumberAnimation {
                        target: liquidFillBg
                        property: "width"
                        from: 0
                        to: (expandedPill.width - 4) * root.percentage
                        duration: 1500
                        easing.type: Easing.OutCubic
                    }
                }
                
                // Shimmer
                Rectangle {
                    id: liquidShimmer
                    visible: false
                }
            }
            
            // Percentage centered
            Text {
                anchors.centerIn: parent
                text: batteryLevel + "%"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
                font.weight: Font.Bold
                color: pywal.foreground
            }
        }
    }
}
