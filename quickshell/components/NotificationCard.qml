import QtQuick 6.10
import QtQuick.Layouts
import "../services" as QsServices
import "../config" as QsConfig

Item {
    id: root

    required property var notification

    // Feature flags
    property bool showCloseButton: true
    property bool showTimestamp: false
    property bool showUnreadDot: false
    property bool showActions: true
    property bool showBody: true
    property bool showAppIcon: true
    property bool deleteOnClose: false

    // Color tokens (overridable by consumer)
    property color primaryColor: pywal?.primary ?? "#88cc88"
    property color onSurfaceColor: pywal?.foreground ?? "#dddddd"
    property color onSurfaceVariantColor: pywal?.onSurfaceMuted ?? "#999999"
    property color errorColor: pywal?.error ?? "#ff4444"
    property color surfaceContainerHighColor: pywal?.surfaceContainerHigh ?? "#1a1a1a"

    property var pywal: null

    function urgencyColor(urgency) {
        if (urgency === 2) return errorColor
        if (urgency === 0) return Qt.rgba(onSurfaceColor.r, onSurfaceColor.g, onSurfaceColor.b, 0.5)
        return primaryColor
    }

    function iconSource(icon) {
        if (!icon) return ""
        if (icon.startsWith("/") || icon.startsWith("file://")) return icon
        return "image://icon/" + icon
    }

    function isBluetoothNotification() {
        const text = `${notification?.appName ?? ""} ${notification?.appIcon ?? ""} ${notification?.summary ?? ""}`.toLowerCase()
        return text.includes("bluetooth") || text.includes("blueman")
    }

    function isNetworkNotification() {
        const text = `${notification?.appName ?? ""} ${notification?.appIcon ?? ""} ${notification?.summary ?? ""} ${notification?.body ?? ""}`.toLowerCase()
        return text.includes("network")
            || text.includes("nm-connection-editor")
            || text.includes("networkmanager")
            || text.includes("nm-applet")
            || text.includes("wifi")
            || text.includes("wi-fi")
            || text.includes("wireless")
            || text.includes("gestor de la red")
            || text.includes("red inalámbrica")
            || text.includes("red inalambrica")
            || text.includes("inalámbrica")
            || text.includes("inalambrica")
    }

    function fallbackIcon() {
        if (isBluetoothNotification()) return "󰂯"
        if (isNetworkNotification()) return "󰖩"
        return "󰂚"
    }

    function shouldLoadAppIcon() {
        return !!notification?.appIcon && notification.appIcon.length > 0 && !isBluetoothNotification() && !isNetworkNotification()
    }

    function dismissNotification() {
        if (!root.notification)
            return
        if (deleteOnClose)
            QsServices.Notifs.deleteNotification(root.notification)
        else if (root.notification.close)
            root.notification.close()
    }

    implicitHeight: contentLayout.implicitHeight

    ColumnLayout {
        id: contentLayout
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 8

        // --- Header Row: icon + summary + timestamp + close ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // App icon
            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                Layout.alignment: Qt.AlignTop
                radius: 12
                visible: showAppIcon
                color: Qt.rgba(urgencyColor(notification?.urgency ?? 1).r,
                               urgencyColor(notification?.urgency ?? 1).g,
                               urgencyColor(notification?.urgency ?? 1).b, 0.12)

                Image {
                    id: appIconImage
                    anchors.centerIn: parent
                    width: 20; height: 20
                    visible: root.shouldLoadAppIcon() && status !== Image.Error
                    source: root.shouldLoadAppIcon() ? root.iconSource(notification?.appIcon ?? "") : ""
                    fillMode: Image.PreserveAspectFit
                    smooth: true; cache: true; asynchronous: true
                }

                Text {
                    anchors.centerIn: parent
                    visible: !root.shouldLoadAppIcon() || appIconImage.status === Image.Error
                    text: root.fallbackIcon()
                    font.family: "Material Design Icons"
                    font.pixelSize: 18
                    color: urgencyColor(notification?.urgency ?? 1)
                    opacity: 0.8
                }
            }

            // Summary + app name
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: notification?.summary ?? "Notification"
                    font.family: QsConfig.Config.appearance.fontFamily ?? "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: onSurfaceColor
                    elide: Text.ElideRight
                    font.letterSpacing: -0.15
                }

                Text {
                    Layout.fillWidth: true
                    text: notification?.appName ?? ""
                    font.family: QsConfig.Config.appearance.fontFamily ?? "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    color: onSurfaceVariantColor
                    elide: Text.ElideRight
                    visible: text.length > 0
                }
            }

            // Unread dot
            Rectangle {
                Layout.preferredWidth: 8
                Layout.preferredHeight: 8
                Layout.alignment: Qt.AlignTop
                radius: 4
                visible: showUnreadDot && notification && !notification.read
                color: primaryColor
                Layout.topMargin: 4
            }

            // Timestamp
            Text {
                visible: showTimestamp
                text: notification?.timeString ?? ""
                font.family: QsConfig.Config.appearance.fontFamily ?? "JetBrainsMono Nerd Font"
                font.pixelSize: 10
                color: onSurfaceVariantColor
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 2
            }

            // Close button
            Rectangle {
                Layout.preferredWidth: 26
                Layout.preferredHeight: 26
                Layout.alignment: Qt.AlignTop
                radius: 13
                visible: showCloseButton
                color: closeMouse.containsMouse
                    ? Qt.rgba(errorColor.r, errorColor.g, errorColor.b, 0.12)
                    : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: "󰅖"
                    font.family: "Material Design Icons"
                    font.pixelSize: 13
                    color: closeMouse.containsMouse ? errorColor : Qt.rgba(onSurfaceColor.r, onSurfaceColor.g, onSurfaceColor.b, 0.45)
                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.dismissNotification()
                    }
                }
            }
        }

        // --- Body text ---
        Text {
            Layout.fillWidth: true
            text: notification?.body ?? ""
            font.family: QsConfig.Config.appearance.fontFamily ?? "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            color: onSurfaceVariantColor
            wrapMode: Text.WordWrap
            maximumLineCount: 3
            elide: Text.ElideRight
            lineHeight: 1.4
            visible: showBody && text.length > 0
        }

        // --- Image preview ---
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            radius: 10
            clip: true
            visible: notification?.image && notification.image.length > 0
            color: surfaceContainerHighColor

            Image {
                anchors.fill: parent
                anchors.margins: 1
                source: root.iconSource(notification?.image ?? "")
                fillMode: Image.PreserveAspectCrop
                smooth: true; cache: true; asynchronous: true
            }
        }

        // --- Action buttons ---
        Flow {
            Layout.fillWidth: true
            spacing: 6
            visible: showActions && notification?.actions && notification.actions.length > 0

            Repeater {
                model: notification?.actions ?? []

                Rectangle {
                    required property var modelData
                    width: actionLabel.implicitWidth + 22
                    height: 28
                    radius: 14
                    color: actionMouse.containsMouse
                        ? Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.18)
                        : Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.10)
                    Behavior on color { ColorAnimation { duration: 120 } }
                    scale: actionMouse.pressed ? 0.94 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

                    Text {
                        id: actionLabel
                        anchors.centerIn: parent
                        text: modelData.text ?? modelData.identifier ?? ""
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        font.family: QsConfig.Config.appearance.fontFamily ?? "JetBrainsMono Nerd Font"
                        font.letterSpacing: 0.3
                        color: primaryColor
                    }

                    MouseArea {
                        id: actionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.invoke)
                                modelData.invoke()
                            root.dismissNotification()
                        }
                    }
                }
            }
        }
    }
}
