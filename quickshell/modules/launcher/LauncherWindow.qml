import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10 as QQC
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import "../../config" as QsConfig
import "../../services" as QsServices
import "../../components"

PanelWindow {
    id: root

    property bool shouldShow: false
    property bool instantClose: false
    property string launcherMode: "apps"
    property string query: ""
    property int selectedIndex: 0
    property bool inputFocused: true
    property bool resultsFocused: false
    property var fileEntries: []
    property var wallpaperEntries: []
    property string fileSearchQuery: ""
    property string wallpaperSearchQuery: ""
    readonly property int wallpaperColumns: 3
    readonly property int listEntryHeight: 66
    readonly property int listEntrySpacing: 8

    readonly property var config: QsConfig.Config
    readonly property var pywal: QsServices.Pywal
    readonly property color cSurface: pywal.surfaceContainerHighest
    readonly property color cSurfaceContainer: pywal.surfaceContainerHigh
    readonly property color cSurfaceContainerHigh: pywal.surfaceContainerHigh
    readonly property color cPrimary: pywal.primary
    readonly property color cText: pywal.foreground
    readonly property color cSubText: pywal.onSurfaceMuted
    readonly property color cBorder: pywal.outlineVariant
    readonly property var terminalCommand: Array.isArray(config.launcher.terminalCommand) && config.launcher.terminalCommand.length > 0
        ? config.launcher.terminalCommand
        : ["foot"]
    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string wallpaperDir: `${homeDir}/Escritorio/3.Recursos/Imagenes`
    readonly property string wallpaperSetter: `${homeDir}/Escritorio/3.Recursos/dotfiles/Scripts/config/set_wallpaper.sh`
    readonly property string libreOfficeApp: `${homeDir}/Escritorio/3.Recursos/AppImages/LibreOffice.AppImage`
    readonly property string koreaderApp: `${homeDir}/Escritorio/3.Recursos/AppImages/Koreader.AppImage`
    readonly property var hiddenPathPrefixes: [
        `${homeDir}/Escritorio/1.Projectos/Universidad/`,
        `${homeDir}/Escritorio/1.Projectos/`,
        `${homeDir}/Escritorio/2.Areas/`,
        `${homeDir}/Escritorio/3.Recursos/`,
        `${homeDir}/Escritorio/4.Archivar/`
    ]
    readonly property string trimmedQuery: query.trim()
    readonly property bool actionMode: launcherMode === "apps" && query.startsWith(">")
    readonly property string searchTerm: {
        if (actionMode)
            return query.slice(1).trim()
        return trimmedQuery
    }

    readonly property var actionEntries: [
        {
            id: "action-terminal",
            name: "Open Terminal",
            comment: "Launch your configured terminal",
            glyph: "󰆍",
            type: "action",
            onTriggered: () => Quickshell.execDetached(terminalCommand)
        },
        {
            id: "action-files",
            name: "Open Files",
            comment: "Open your home directory",
            glyph: "󰉋",
            type: "action",
            onTriggered: () => Quickshell.execDetached(["xdg-open", Quickshell.env("HOME")])
        },
        {
            id: "action-network",
            name: "Network Settings",
            comment: "Open nm-connection-editor",
            glyph: "󰖩",
            type: "action",
            onTriggered: () => Quickshell.execDetached(["nm-connection-editor"])
        }
    ]

    readonly property var favoriteApps: {
        const favorites = config.launcher.favorites ?? []
        const apps = DesktopEntries.applications.values ?? []
        return favorites
            .map(favoriteId => apps.find(entry => entry.id === favoriteId || entry.name === favoriteId))
            .filter(entry => !!entry)
    }

    readonly property var appEntries: {
        const apps = DesktopEntries.applications.values ?? []
        const q = searchTerm.toLowerCase()
        const favoriteIds = (favoriteApps ?? []).map(entry => entry.id)

        function score(entry) {
            const name = (entry.name ?? "").toLowerCase()
            const genericName = (entry.genericName ?? "").toLowerCase()
            const comment = (entry.comment ?? "").toLowerCase()
            const execString = (entry.execString ?? "").toLowerCase()
            const id = (entry.id ?? "").toLowerCase()
            let rank = 0

            if (!q.length)
                rank = favoriteIds.includes(entry.id) ? 200 : 100
            else if (name === q)
                rank = 1000
            else if (name.startsWith(q))
                rank = 900
            else if (genericName.startsWith(q) || id.startsWith(q))
                rank = 760
            else if (name.includes(q))
                rank = 680
            else if (genericName.includes(q) || comment.includes(q))
                rank = 520
            else if (execString.includes(q))
                rank = 420

            if (favoriteIds.includes(entry.id))
                rank += 90

            return rank
        }

        const filtered = apps
            .map(entry => ({ entry, rank: score(entry) }))
            .filter(item => item.rank > 0)
            .sort((left, right) => {
                if (right.rank !== left.rank)
                    return right.rank - left.rank
                return (left.entry.name ?? "").localeCompare(right.entry.name ?? "")
            })
            .slice(0, config.launcher.maxResults)
            .map(item => item.entry)

        if (!q.length && filtered.length === 0)
            return (apps ?? []).slice(0, config.launcher.maxResults)

        return filtered
    }

    readonly property var visibleEntries: {
        const q = searchTerm
        if (actionMode) {
            const actionQuery = q.toLowerCase()
            return actionEntries.filter(entry => {
                if (!actionQuery.length)
                    return true
                return entry.name.toLowerCase().includes(actionQuery) || entry.comment.toLowerCase().includes(actionQuery)
            })
        }

        if (launcherMode === "files")
            return fileEntries.slice(0, config.launcher.maxResults)

        if (launcherMode === "wallpapers")
            return wallpaperEntries

        if (!q.length && favoriteApps.length > 0)
            return favoriteApps.slice(0, config.launcher.maxResults)

        return [
            ...appEntries.slice(0, Math.max(3, config.launcher.maxResults - 4)),
            ...fileEntries.slice(0, 3),
            ...wallpaperEntries.slice(0, 2)
        ].slice(0, config.launcher.maxResults)
    }

    function compactPath(path) {
        if (!path)
            return ""
        for (let i = 0; i < hiddenPathPrefixes.length; i++) {
            const prefix = hiddenPathPrefixes[i]
            if (path.startsWith(prefix))
                return path.slice(prefix.length)
        }
        return path.startsWith(`${homeDir}/`) ? `~/${path.slice(homeDir.length + 1)}` : path
    }

    function entryIconSource(entry) {
        const icon = entry?.icon
        if (!icon)
            return ""

        const iconName = typeof icon === "string" ? icon : (icon.name ?? "")
        if (!iconName)
            return ""

        if (iconName.startsWith("/") || iconName.startsWith("file://"))
            return iconName

        return Quickshell.iconPath(iconName, "")
    }

    function commandForFile(path) {
        if (path.endsWith(".pdf"))
            return ["zathura", path]
        if (path.endsWith(".xls") || path.endsWith(".xlsx") || path.endsWith(".ods") || path.endsWith(".csv") || path.endsWith(".docx"))
            return [libreOfficeApp, path]
        if (path.endsWith(".epub"))
            return [koreaderApp, path]
        return ["xdg-open", path]
    }

    function fuzzyScore(needle, haystack) {
        const q = (needle ?? "").toLowerCase().trim()
        const text = (haystack ?? "").toLowerCase()
        if (!q.length)
            return 1
        if (text === q)
            return 2000
        if (text.startsWith(q))
            return 1400
        const includeIndex = text.indexOf(q)
        let score = includeIndex >= 0 ? 900 - Math.min(includeIndex, 200) : 0

        let qi = 0
        let streak = 0
        let subseq = 0
        for (let i = 0; i < text.length && qi < q.length; i++) {
            if (text[i] === q[qi]) {
                qi += 1
                streak += 1
                subseq += 30 + Math.min(streak, 6) * 8
            } else {
                streak = 0
            }
        }

        if (qi !== q.length)
            return score

        return Math.max(score, 500 + subseq - Math.max(0, text.length - q.length))
    }

    function fileRank(path) {
        const compact = compactPath(path)
        const name = path.split("/").pop()
        return Math.max(
            fuzzyScore(searchTerm, name),
            fuzzyScore(searchTerm, compact),
            fuzzyScore(searchTerm, path)
        )
    }

    function wallpaperRank(path) {
        const name = path.split("/").pop()
        return Math.max(
            fuzzyScore(searchTerm, name),
            fuzzyScore(searchTerm, path)
        )
    }

    function closeLauncher(immediate) {
        instantClose = !!immediate
        shouldShow = false
        setQueryText("")
        resetNavigation()
        fileEntries = []
        wallpaperEntries = []
    }

    function setQueryText(text) {
        query = text
        searchField.text = text
    }

    function resetNavigation() {
        inputFocused = true
        resultsFocused = false
        selectedIndex = 0
        if (resultsFlick)
            resultsFlick.contentY = 0
    }

    function claimKeyboardFocus() {
        searchField.forceActiveFocus()
    }

    function moveList(step) {
        if (launcherMode === "wallpapers" || visibleEntries.length === 0)
            return
        const next = selectedIndex + step
        if (step < 0 && selectedIndex === 0) {
            returnToInput()
            return
        }
        selectedIndex = Math.max(0, Math.min(next, visibleEntries.length - 1))
    }

    function enterResults() {
        if (visibleEntries.length === 0)
            return false
        selectedIndex = 0
        inputFocused = false
        resultsFocused = true
        searchField.forceActiveFocus()
        return true
    }

    function returnToInput() {
        inputFocused = true
        resultsFocused = false
        searchField.forceActiveFocus()
    }

    function moveWallpaperHorizontal(step) {
        if (launcherMode !== "wallpapers" || visibleEntries.length === 0)
            return
        const next = selectedIndex + step
        if (next < 0 || next >= visibleEntries.length)
            return
        if (Math.floor(next / wallpaperColumns) === Math.floor(selectedIndex / wallpaperColumns))
            selectedIndex = next
    }

    function moveWallpaperVertical(step) {
        if (launcherMode !== "wallpapers" || visibleEntries.length === 0)
            return
        if (step < 0 && selectedIndex < wallpaperColumns) {
            returnToInput()
            return
        }
        const next = selectedIndex + (step * wallpaperColumns)
        selectedIndex = Math.max(0, Math.min(next, visibleEntries.length - 1))
        ensureWallpaperSelectionVisible()
    }

    function ensureWallpaperSelectionVisible() {
        if (launcherMode !== "wallpapers" || !resultsFlick || !wallpaperGrid || wallpaperGrid.tileHeight <= 0)
            return

        const row = Math.floor(selectedIndex / wallpaperColumns)
        const rowTop = row * (wallpaperGrid.tileHeight + wallpaperGrid.rowSpacing)
        const rowBottom = rowTop + wallpaperGrid.tileHeight
        const viewTop = resultsFlick.contentY
        const viewBottom = viewTop + resultsFlick.height

        if (rowBottom > viewBottom)
            resultsFlick.contentY = Math.min(rowBottom - resultsFlick.height, Math.max(0, resultsFlick.contentHeight - resultsFlick.height))
        else if (rowTop < viewTop)
            resultsFlick.contentY = Math.max(0, rowTop)
    }

    function ensureListSelectionVisible() {
        if (launcherMode === "wallpapers" || !resultsFlick || listEntryHeight <= 0)
            return

        const itemTop = selectedIndex * (listEntryHeight + listEntrySpacing)
        const itemBottom = itemTop + listEntryHeight
        const viewTop = resultsFlick.contentY
        const viewBottom = viewTop + resultsFlick.height
        const maxScroll = Math.max(0, resultsFlick.contentHeight - resultsFlick.height)

        if (itemBottom > viewBottom)
            resultsFlick.contentY = Math.min(itemBottom - resultsFlick.height, maxScroll)
        else if (itemTop < viewTop)
            resultsFlick.contentY = Math.max(0, itemTop)
    }

    function ensureSelectionVisible() {
        if (launcherMode === "wallpapers")
            ensureWallpaperSelectionVisible()
        else
            ensureListSelectionVisible()
    }

    function handleMoveDown() {
        if (inputFocused)
            return enterResults()
        if (!resultsFocused || visibleEntries.length === 0)
            return false
        if (launcherMode === "wallpapers")
            moveWallpaperVertical(1)
        else
            moveList(1)
        return true
    }

    function handleMoveUp() {
        if (!resultsFocused || visibleEntries.length === 0)
            return false
        if (launcherMode === "wallpapers")
            moveWallpaperVertical(-1)
        else
            moveList(-1)
        return true
    }

    function handleMoveLeft() {
        if (!resultsFocused)
            return false
        if (launcherMode === "wallpapers")
            moveWallpaperHorizontal(-1)
        return true
    }

    function handleMoveRight() {
        if (!resultsFocused)
            return false
        if (launcherMode === "wallpapers")
            moveWallpaperHorizontal(1)
        return true
    }

    function handleAcceptSelection() {
        if (visibleEntries.length === 0)
            return false
        launchEntry(resultsFocused ? visibleEntries[selectedIndex] : visibleEntries[0])
        return true
    }

    function openLauncher() {
        instantClose = false
        shouldShow = true
        resetNavigation()
        setQueryText("")
        if (launcherMode === "wallpapers")
            searchDebounce.restart()
        launcherFocusRetry.restart()
    }

    function launchEntry(entry) {
        if (!entry)
            return

        if (entry.type === "wallpaper" && entry.onTriggered) {
            closeLauncher(true)
            Qt.callLater(() => entry.onTriggered())
            return
        }

        if (entry.onTriggered) {
            entry.onTriggered()
            closeLauncher()
            return
        }

        if (entry.runInTerminal) {
            Quickshell.execDetached({
                command: [...terminalCommand, ...entry.command],
                workingDirectory: entry.workingDirectory
            })
        } else {
            Quickshell.execDetached({
                command: entry.command,
                workingDirectory: entry.workingDirectory
            })
        }

        closeLauncher()
    }

    onShouldShowChanged: {
        if (shouldShow) {
            resetNavigation()
            launcherFocusRetry.restart()
        }
    }

    Timer {
        id: launcherFocusRetry
        interval: 40
        repeat: false
        onTriggered: {
            root.claimKeyboardFocus()
            Qt.callLater(() => root.claimKeyboardFocus())
        }
    }

    onVisibleEntriesChanged: {
        if (visibleEntries.length === 0) {
            if (resultsFocused)
                returnToInput()
            return
        }
        if (selectedIndex >= visibleEntries.length)
            selectedIndex = Math.max(0, visibleEntries.length - 1)
    }

    onSelectedIndexChanged: ensureSelectionVisible()

    onQueryChanged: searchDebounce.restart()

    Timer {
        id: searchDebounce
        interval: 160
        repeat: false
        onTriggered: {
            const q = root.searchTerm
            if (root.actionMode || (!q.length && root.launcherMode !== "wallpapers")) {
                root.fileEntries = []
                root.wallpaperEntries = []
                return
            }

            if (root.launcherMode === "files" && !fileSearchProc.running) {
                root.fileSearchQuery = q
                fileSearchProc.command = [
                    "fd",
                    "-i",
                    "-a",
                    ".",
                    "-e", "pdf",
                    "-e", "xls",
                    "-e", "xlsx",
                    "-e", "ods",
                    "-e", "docx",
                    "-e", "csv",
                    "-e", "epub",
                    root.homeDir
                ]
                fileSearchProc.running = true
            }

            if (root.launcherMode === "wallpapers" && !wallpaperSearchProc.running) {
                root.wallpaperSearchQuery = q
                wallpaperSearchProc.command = [
                    "fd",
                    "-i",
                    "-a",
                    ".",
                    "-d", "2",
                    "-e", "jpg",
                    "-e", "jpeg",
                    "-e", "png",
                    "-e", "gif",
                    root.wallpaperDir
                ]
                wallpaperSearchProc.running = true
            }
        }
    }

    Process {
        id: fileSearchProc
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.searchTerm !== root.fileSearchQuery) {
                    searchDebounce.restart()
                    return
                }
                const lines = text.trim().length ? text.trim().split("\n") : []
                root.fileEntries = lines
                    .map(path => ({ path, rank: root.fileRank(path) }))
                    .filter(item => item.rank > 0)
                    .sort((left, right) => right.rank - left.rank || left.path.localeCompare(right.path))
                    .slice(0, config.launcher.maxResults)
                    .map(item => ({
                        id: `file-${item.path}`,
                        name: item.path.split("/").pop(),
                        comment: root.compactPath(item.path),
                        glyph: "󰈔",
                        type: "file",
                        onTriggered: () => Quickshell.execDetached(root.commandForFile(item.path))
                    }))
            }
        }
    }

    Process {
        id: wallpaperSearchProc
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.searchTerm !== root.wallpaperSearchQuery) {
                    searchDebounce.restart()
                    return
                }
                const lines = text.trim().length ? text.trim().split("\n") : []
                root.wallpaperEntries = lines
                    .filter(path => {
                        const relative = path.startsWith(`${root.wallpaperDir}/`)
                            ? path.slice(root.wallpaperDir.length + 1)
                            : ""
                        return relative.includes("/")
                    })
                    .map(path => ({ path, rank: root.wallpaperRank(path) }))
                    .filter(item => item.rank > 0)
                    .sort((left, right) => right.rank - left.rank || left.path.localeCompare(right.path))
                    .map(item => ({
                        id: `wallpaper-${item.path}`,
                        name: item.path.split("/").pop(),
                        source: item.path,
                        comment: "Set wallpaper",
                        glyph: "󰸉",
                        type: "wallpaper",
                        onTriggered: () => Quickshell.execDetached([root.wallpaperSetter, item.path])
                    }))
            }
        }
    }

    screen: Quickshell.screens[0]
    anchors {
        top: true
        left: true
    }
    margins {
        top: (config.bar.height ?? 34) + 22
        left: Math.max(0, Math.round((screen.width - root.implicitWidth) / 2))
    }
    implicitWidth: config.launcher.width
    implicitHeight: shouldShow || panel.opacity > 0 ? panelColumn.implicitHeight + 40 : 0
    color: "transparent"
    visible: config.launcher.enabled && (shouldShow || (!instantClose && panel.opacity > 0))

    WlrLayershell.keyboardFocus: shouldShow ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        FocusScope {
            id: panel
            anchors.fill: parent
        property real revealOffset: shouldShow ? 0 : -20
        scale: shouldShow ? 1.0 : 0.97
        opacity: shouldShow ? 1.0 : 0.0
        focus: root.shouldShow
            transform: Translate { y: panel.revealOffset }

            Keys.onEscapePressed: root.closeLauncher()
            Keys.onDownPressed: event => {
                if (root.handleMoveDown())
                    event.accepted = true
            }
            Keys.onUpPressed: event => {
                if (root.handleMoveUp())
                    event.accepted = true
            }
            Keys.onLeftPressed: event => {
                if (root.handleMoveLeft())
                    event.accepted = true
            }
            Keys.onRightPressed: event => {
                if (root.handleMoveRight())
                    event.accepted = true
            }
            Keys.onReturnPressed: event => {
                if (root.handleAcceptSelection())
                    event.accepted = true
            }
            Keys.onEnterPressed: event => {
                if (root.handleAcceptSelection())
                    event.accepted = true
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                onPressed: root.claimKeyboardFocus()
                z: -1
            }

        Behavior on scale {
            NumberAnimation { duration: root.instantClose ? 0 : 240; easing.bezierCurve: [0.22, 1.0, 0.36, 1.0] }
        }

        Behavior on opacity {
            NumberAnimation { duration: root.instantClose ? 0 : 180; easing.type: Easing.OutQuad }
        }

        Behavior on revealOffset {
            NumberAnimation { duration: root.instantClose ? 0 : 260; easing.bezierCurve: [0.05, 0.7, 0.1, 1.0] }
        }

        AuroraSurface {
            anchors.fill: parent
            radius: 28
            color: root.cSurface
            strokeColor: root.cBorder
            accentColor: root.cPrimary
            elevation: 4
            shadowEnabled: true
            highlighted: root.shouldShow

            ColumnLayout {
                id: panelColumn
                anchors.fill: parent
                anchors.margins: 18
                spacing: 16

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 62
                    radius: 22
                    color: root.cSurfaceContainer
                    border.width: 1
                    border.color: Qt.rgba(root.cPrimary.r, root.cPrimary.g, root.cPrimary.b, 0.18)

                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: Qt.rgba(root.cPrimary.r, root.cPrimary.g, root.cPrimary.b, 0.04)
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        Text {
                            text: query.trim().startsWith(">") ? "󰘳" : "󰍉"
                            font.family: "Material Design Icons"
                            font.pixelSize: 22
                            color: root.cPrimary
                        }

                        QQC.TextField {
                            id: searchField
                            Layout.fillWidth: true
                            color: root.cText
                            font.family: QsConfig.Config.appearance.fontFamily
                            font.pixelSize: 15
                            placeholderText: root.launcherMode === "files"
                                ? "Search files or path"
                                : root.launcherMode === "wallpapers"
                                    ? "Search wallpapers"
                                    : 'Search apps or type ">" for actions'
                            placeholderTextColor: root.cSubText
                            background: Item {}
                            selectByMouse: true
                            Keys.priority: Keys.BeforeItem
                            Keys.onUpPressed: event => {
                                if (root.handleMoveUp())
                                    event.accepted = true
                            }
                            Keys.onDownPressed: event => {
                                if (root.handleMoveDown())
                                    event.accepted = true
                            }
                            Keys.onLeftPressed: event => {
                                if (root.handleMoveLeft())
                                    event.accepted = true
                            }
                            Keys.onRightPressed: event => {
                                if (root.handleMoveRight())
                                    event.accepted = true
                            }
                            Keys.onReturnPressed: event => {
                                if (root.handleAcceptSelection())
                                    event.accepted = true
                            }
                            Keys.onEnterPressed: event => {
                                if (root.handleAcceptSelection())
                                    event.accepted = true
                            }

                            onTextChanged: {
                                root.query = text
                                root.resetNavigation()
                            }
                        }

                        Text {
                            visible: query.length > 0
                            text: "Esc"
                            font.family: QsConfig.Config.appearance.fontFamily
                            font.pixelSize: 11
                            color: root.cSubText
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text: root.actionMode ? "Quick actions"
                            : root.launcherMode === "files" ? "Files"
                            : root.launcherMode === "wallpapers" ? "Wallpapers"
                            : (root.searchTerm.length ? "Apps" : "Favorites")
                        font.family: QsConfig.Config.appearance.fontFamily
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: root.cText
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: `${root.visibleEntries.length} item${root.visibleEntries.length === 1 ? "" : "s"}`
                        font.family: QsConfig.Config.appearance.fontFamily
                        font.pixelSize: 11
                        color: root.cSubText
                    }
                }

                Flickable {
                    id: resultsFlick
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.launcherMode === "wallpapers"
                        ? Math.min(560, wallpaperGrid.implicitHeight + 12)
                        : Math.min(520, listColumn.implicitHeight + 12)
                    clip: true
                    contentWidth: width
                    contentHeight: root.launcherMode === "wallpapers" ? wallpaperGrid.implicitHeight : listColumn.implicitHeight
                    boundsBehavior: Flickable.StopAtBounds

                    QQC.ScrollBar.vertical: QQC.ScrollBar {
                        policy: QQC.ScrollBar.AsNeeded
                        visible: root.launcherMode !== "wallpapers"
                    }

                    Column {
                        id: listColumn
                        width: root.width - 48
                        spacing: root.listEntrySpacing
                        visible: root.launcherMode !== "wallpapers"

                        Repeater {
                            model: root.visibleEntries

                            Rectangle {
                                id: delegateRoot
                                required property var modelData
                                required property int index
                                readonly property bool isSelected: root.selectedIndex === index
                                readonly property bool isHovered: hovered.hovered && !isSelected
                                readonly property string iconSource: root.entryIconSource(modelData)

                                width: listColumn.width
                                height: root.listEntryHeight
                                radius: 20
                                color: isSelected
                                    ? Qt.rgba(root.cPrimary.r, root.cPrimary.g, root.cPrimary.b, 0.18)
                                    : isHovered
                                        ? root.cSurfaceContainerHigh
                                        : root.cSurfaceContainer
                                border.width: isSelected ? 2 : 1
                                border.color: isSelected
                                    ? Qt.rgba(root.cPrimary.r, root.cPrimary.g, root.cPrimary.b, 0.62)
                                    : isHovered
                                        ? Qt.rgba(root.cPrimary.r, root.cPrimary.g, root.cPrimary.b, 0.18)
                                        : Qt.rgba(root.cText.r, root.cText.g, root.cText.b, 0.10)
                                scale: isHovered ? 1.01 : 1.0

                                Behavior on scale { NumberAnimation { duration: 80; easing.bezierCurve: [0.22, 1.0, 0.36, 1.0] } }

                                Rectangle {
                                    anchors.fill: parent
                                    radius: parent.radius
                                    color: Qt.rgba(root.cPrimary.r, root.cPrimary.g, root.cPrimary.b, isSelected ? 0.08 : isHovered ? 0.03 : 0)
                                }

                                HoverHandler { id: hovered }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Rectangle {
                                        Layout.preferredWidth: 40
                                        Layout.preferredHeight: 40
                                        radius: 14
                                        color: Qt.rgba(root.cPrimary.r, root.cPrimary.g, root.cPrimary.b, delegateRoot.modelData.type === "action" ? 0.14 : 0.10)

                                        Image {
                                            id: entryIconImage
                                            anchors.centerIn: parent
                                            width: 22
                                            height: 22
                                            visible: delegateRoot.modelData.type !== "action" && delegateRoot.iconSource.length > 0 && status !== Image.Error
                                            source: delegateRoot.iconSource
                                            fillMode: Image.PreserveAspectFit
                                            smooth: true
                                            cache: true
                                            asynchronous: true
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            visible: !entryIconImage.visible
                                            text: delegateRoot.modelData.glyph
                                                ? delegateRoot.modelData.glyph
                                                : ((delegateRoot.modelData.name ?? "?").slice(0, 1).toUpperCase())
                                            font.family: delegateRoot.modelData.glyph
                                                ? "Material Design Icons"
                                                : QsConfig.Config.appearance.fontFamily
                                            font.pixelSize: delegateRoot.modelData.glyph ? 20 : 16
                                            font.weight: Font.DemiBold
                                            color: root.cPrimary
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        Text {
                                            Layout.fillWidth: true
                                            text: delegateRoot.modelData.name ?? "Unknown"
                                            font.family: QsConfig.Config.appearance.fontFamily
                                            font.pixelSize: 14
                                            font.weight: Font.Medium
                                            color: root.cText
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: delegateRoot.modelData.comment || delegateRoot.modelData.genericName || delegateRoot.modelData.execString || "Launch"
                                            font.family: QsConfig.Config.appearance.fontFamily
                                            font.pixelSize: 11
                                            color: root.cSubText
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Text {
                                        visible: delegateRoot.isSelected
                                        text: "󰁔"
                                        font.family: "Material Design Icons"
                                        font.pixelSize: 18
                                        color: root.cPrimary
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: root.selectedIndex = delegateRoot.index
                                    onClicked: root.launchEntry(delegateRoot.modelData)
                                }
                            }
                        }
                    }

                    GridLayout {
                        id: wallpaperGrid
                        visible: root.launcherMode === "wallpapers"
                        width: resultsFlick.width
                        columns: root.wallpaperColumns
                        columnSpacing: 10
                        rowSpacing: 10
                        readonly property real tileWidth: Math.floor((width - ((root.wallpaperColumns - 1) * columnSpacing)) / root.wallpaperColumns)
                        readonly property real tileHeight: Math.round(tileWidth * 0.62)

                        Repeater {
                            model: root.visibleEntries

                            Rectangle {
                                id: wallpaperTile
                                required property var modelData
                                required property int index
                                readonly property bool isSelected: root.selectedIndex === index
                                readonly property bool isHovered: wallpaperHover.hovered && !isSelected

                                Layout.preferredWidth: wallpaperGrid.tileWidth
                                Layout.preferredHeight: wallpaperGrid.tileHeight
                                radius: 18
                                clip: true
                                color: root.cSurfaceContainer
                                border.width: isSelected ? 3 : 1
                                border.color: isSelected
                                    ? Qt.rgba(root.cPrimary.r, root.cPrimary.g, root.cPrimary.b, 0.9)
                                    : isHovered
                                        ? Qt.rgba(root.cPrimary.r, root.cPrimary.g, root.cPrimary.b, 0.28)
                                    : Qt.rgba(root.cText.r, root.cText.g, root.cText.b, 0.12)
                                scale: isSelected ? 1.03 : isHovered ? 1.01 : 1.0

                                Behavior on border.color { ColorAnimation { duration: 160 } }
                                Behavior on scale { NumberAnimation { duration: 160 } }

                                Image {
                                    anchors.fill: parent
                                    source: wallpaperTile.modelData.source ?? ""
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: true
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    color: Qt.rgba(0, 0, 0, isSelected ? 0.03 : isHovered ? 0.06 : 0.18)
                                }

                                Rectangle {
                                    visible: wallpaperTile.isSelected
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    anchors.margins: 10
                                    width: 30
                                    height: 30
                                    radius: 15
                                    color: Qt.rgba(root.cSurface.r, root.cSurface.g, root.cSurface.b, 0.86)
                                    border.width: 1
                                    border.color: Qt.rgba(root.cPrimary.r, root.cPrimary.g, root.cPrimary.b, 0.75)

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰄬"
                                        font.family: "Material Design Icons"
                                        font.pixelSize: 18
                                        color: root.cPrimary
                                    }
                                }

                                HoverHandler { id: wallpaperHover }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: root.selectedIndex = wallpaperTile.index
                                    onClicked: root.launchEntry(wallpaperTile.modelData)
                                }
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: root.visibleEntries.length === 0
                    text: root.actionMode ? "No actions matched."
                        : root.launcherMode === "files" ? "No files matched."
                        : root.launcherMode === "wallpapers" ? "No wallpapers matched."
                        : "No applications matched your search."
                    horizontalAlignment: Text.AlignHCenter
                    font.family: QsConfig.Config.appearance.fontFamily
                    font.pixelSize: 12
                    color: root.cSubText
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton)
                    root.closeLauncher()
            }
        }
    }
}
