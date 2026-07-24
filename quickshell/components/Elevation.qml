import QtQuick 6.10
import QtQuick.Effects

Item {
    id: root

    property bool enabled: false
    property int level: 1
    property color shadowColor: Qt.rgba(0, 0, 0, 0.25)
    property Item target: parent
    property real radius: target?.radius ?? 0

    readonly property var elevationDp: [0, 1, 3, 6, 8, 12]
    readonly property real dp: elevationDp[Math.min(Math.max(0, level), 5)]
    readonly property real blur: Math.pow(dp * 5, 0.7)
    readonly property real spread: -dp * 0.3 + Math.pow(dp * 0.1, 2)
    readonly property real offsetY: dp / 2

    anchors.fill: target
    z: -1
    visible: root.enabled && root.level > 0

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: root.offsetY
        radius: root.radius
        color: "transparent"
        visible: root.visible

        layer.enabled: root.visible
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(
                root.shadowColor.r,
                root.shadowColor.g,
                root.shadowColor.b,
                root.shadowColor.a * 0.6
            )
            shadowBlur: root.blur * 0.6
            shadowVerticalOffset: root.offsetY
            shadowHorizontalOffset: 0
            shadowScale: 1.0 + (root.spread * 0.01)
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: "transparent"
        visible: root.visible

        layer.enabled: root.visible
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(
                root.shadowColor.r,
                root.shadowColor.g,
                root.shadowColor.b,
                root.shadowColor.a * 0.4
            )
            shadowBlur: root.blur
            shadowVerticalOffset: root.dp * 0.25
            shadowHorizontalOffset: 0
            shadowScale: 1.0 + (root.spread * 0.02)
        }
    }
}
