import Quickshell
import QtQuick 6.10
import QtQuick.Layouts 6.10
import "../../../config" as QsConfig
import "../../../services" as QsServices

// Clean workspace container - no outer pill
Item {
    id: root
    
    property var screen
    
    readonly property var config: QsConfig.Config
    readonly property var pywal: QsServices.Pywal
    readonly property var sway: QsServices.Sway
    readonly property int activeWsId: sway.activeWsId
    readonly property var occupied: sway.getOccupiedWorkspaces()
    readonly property var visibleWorkspaceIds: {
        const ids = [1, 2, 3, 4, 5]
        const seen = { 1: true, 2: true, 3: true, 4: true, 5: true }
        const activeId = root.activeWsId

        if (activeId > 5 && !seen[activeId]) {
            ids.push(activeId)
            seen[activeId] = true
        }

        for (const rawId in root.occupied) {
            const id = Number(rawId)
            if (id > 5 && root.occupied[rawId] && !seen[id]) {
                ids.push(id)
                seen[id] = true
            }
        }

        ids.sort((left, right) => left - right)
        return ids
    }
    
    implicitWidth: layout.implicitWidth
    implicitHeight: config.bar.height - config.bar.padding * 2
    
    RowLayout {
        id: layout
        
        anchors.centerIn: parent
        spacing: root.config.bar.workspaces.spacing
        
        Repeater {
            id: workspaceRepeater
            model: root.visibleWorkspaceIds
            
            delegate: Loader {
                required property var modelData
                
                source: "Workspace.qml"
                asynchronous: false
                
                onLoaded: {
                    item.workspaceId = Number(modelData)
                    item.isActive = Qt.binding(() => root.activeWsId === item.workspaceId)
                    item.isOccupied = Qt.binding(() => root.occupied[item.workspaceId] ?? false)
                    item.clicked.connect(function() {
                        if (root.sway.activeWsId !== item.workspaceId) {
                            root.sway.switchWorkspace(item.workspaceId)
                        }
                    })
                }
            }
        }
    }
}
