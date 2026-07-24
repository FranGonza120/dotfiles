pragma Singleton

import QtQuick 6.10
import Quickshell
import Quickshell.I3

Singleton {
    id: root

    readonly property var workspaces: I3.workspaces
    readonly property int activeWsId: I3.focusedWorkspace?.number ?? 1
    property int revision: 0

    Component.onCompleted: I3.refreshWorkspaces()

    function getOccupiedWorkspaces(): var {
        revision
        const occupied = {}

        for (const workspace of I3.workspaces.values) {
            const id = workspace.number
            if (id < 1)
                continue

            occupied[id] = (workspace.lastIpcObject?.representation ?? "") !== ""
        }

        return occupied
    }

    function switchWorkspace(id: int): void {
        const target = findWorkspace(id)
        if (target) {
            target.activate()
            return
        }

        I3.dispatch(`workspace number ${id}`)
    }

    function findWorkspace(id: int): var {
        for (const workspace of I3.workspaces.values) {
            if (workspace.number === id)
                return workspace
        }

        return null
    }

    Connections {
        target: I3

        function onRawEvent(event: var): void {
            root.revision++
        }
    }
}
