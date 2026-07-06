pragma Singleton

import QtQuick 6.10
import Quickshell
import Quickshell.Io
import "../config" as QsConfig
import "." as QsServices

// Screenshot/Screen Recording Service
Singleton {
    id: root
    
    property bool isRecording: false
    property string lastScreenshotPath: ""
    property string lastRecordingPath: ""
    property string screenshotsDir: QsConfig.Config.paths.screenshotsDir

    property string _slurpGeometry: ""
    property string _windowGeomText: ""
    
    Component.onCompleted: {
        // Create screenshots directory if it doesn't exist
        mkdirProc.running = true
    }
    
    Process {
        id: mkdirProc
        command: ["mkdir", "-p", root.screenshotsDir]
    }
    
    function takeScreenshot(mode: string) {
        // mode: "screen", "window", "region"
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19)
        const filename = `screenshot-${timestamp}.png`
        const filepath = `${screenshotsDir}/${filename}`
        
        if (mode === "region") {
            // For region selection, use slurp to get geometry then grim to capture
            slurpProc.exec(["slurp"])
        } else if (mode === "screen") {
            // Capture entire screen
            screenshotProc.exec(["grim", filepath])
            root.lastScreenshotPath = filepath
        } else if (mode === "window") {
            windowGeomProc.exec(["swaymsg", "-t", "get_tree"])
        }
    }

    function focusedNode(node: var): var {
        if (node.focused && node.type === "con")
            return node

        for (const child of node.nodes ?? []) {
            const found = focusedNode(child)
            if (found)
                return found
        }

        for (const child of node.floating_nodes ?? []) {
            const found = focusedNode(child)
            if (found)
                return found
        }

        return null
    }
    
    // Get region geometry with slurp
    Process {
        id: slurpProc
        stdout: StdioCollector {
            onStreamFinished: root._slurpGeometry = text.trim()
        }
        onExited: code => {
            const geometry = root._slurpGeometry
            root._slurpGeometry = ""

            if (code !== 0) {
                QsServices.Logger.error("Screenshot", `slurp failed with code: ${code}`)
                return
            }
            if (geometry === "") {
                return
            }

            const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19)
            const filename = `screenshot-${timestamp}.png`
            const filepath = `${root.screenshotsDir}/${filename}`

            QsServices.Logger.debug("Screenshot", `Capturing region: ${geometry}`)
            screenshotProc.exec(["grim", "-g", geometry, filepath])
            root.lastScreenshotPath = filepath
        }
    }
    
    // Get active window geometry
    Process {
        id: windowGeomProc
        stdout: StdioCollector {
            onStreamFinished: root._windowGeomText = text.trim()
        }
        onExited: code => {
            const out = root._windowGeomText
            root._windowGeomText = ""

            if (code !== 0) {
                QsServices.Logger.error("Screenshot", `window geometry failed with code: ${code}`)
                return
            }
            if (out === "") {
                return
            }

            let rect = null
            try {
                rect = root.focusedNode(JSON.parse(out))?.rect
            } catch (e) {
                QsServices.Logger.warn("Screenshot", `Failed to parse window tree: ${e?.message ?? e}`)
                return
            }

            if (!rect) {
                QsServices.Logger.warn("Screenshot", "No focused window geometry found")
                return
            }

            const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19)
            const filename = `screenshot-${timestamp}.png`
            const filepath = `${root.screenshotsDir}/${filename}`
            const geometry = `${rect.x},${rect.y} ${rect.width}x${rect.height}`

            QsServices.Logger.debug("Screenshot", `Capturing window: ${geometry}`)
            screenshotProc.exec(["grim", "-g", geometry, filepath])
            root.lastScreenshotPath = filepath
        }
    }
    
    Process {
        id: screenshotProc
        onExited: code => {
            if (code === 0) {
                QsServices.Logger.info("Screenshot", `Saved: ${root.lastScreenshotPath}`)
                
                // Copy to clipboard using wl-copy with shell redirection
                var path = root.lastScreenshotPath
                clipboardProc.exec(["sh", "-c", "wl-copy < \"$1\"", "sh", path])
                
                notifyProc.exec([
                    "notify-send",
                    "-i", root.lastScreenshotPath,
                    "Screenshot captured",
                    `Saved and copied to clipboard`
                ])
            } else {
                QsServices.Logger.error("Screenshot", `Failed with code: ${code}`)
            }
        }
    }
    
    Process {
        id: clipboardProc
    }
    
    Process {
        id: notifyProc
    }
    
    function startRecording() {
        if (isRecording) return
        
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19)
        const filename = `recording-${timestamp}.mp4`
        const filepath = `${screenshotsDir}/${filename}`
        root.lastRecordingPath = filepath
        
        recordProc.exec([
            "wf-recorder",
            "-f", filepath,
            "-c", "h264_vaapi",
            "-d", "/dev/dri/renderD128"
        ])
        
        root.isRecording = true
        QsServices.Logger.info("Screenshot", "Recording started")
    }
    
    Process {
        id: recordProc
        onExited: code => {
            root.isRecording = false
            if (code === 0) {
                QsServices.Logger.info("Screenshot", `Recording saved: ${root.lastRecordingPath}`)
                notifyProc.exec([
                    "notify-send",
                    "-i", "video-x-generic",
                    "Screen recording saved",
                    root.lastRecordingPath
                ])
            }
        }
    }
    
    function stopRecording() {
        if (!isRecording) return
        
        stopRecordProc.running = true
        // isRecording will be set to false when the recording process finishes
    }
    
    Process {
        id: stopRecordProc
        command: ["pkill", "-SIGINT", "wf-recorder"]
    }
    
    function openScreenshotsFolder() {
        openProc.exec(["xdg-open", screenshotsDir])
    }
    
    Process {
        id: openProc
    }
    
    function copyLastScreenshot() {
        if (!lastScreenshotPath) return

        var path = lastScreenshotPath
        copyProc.exec(["sh", "-c", "wl-copy < \"$1\"", "sh", path])
    }
    
    Process {
        id: copyProc
    }
    
    function deleteLastScreenshot() {
        if (!lastScreenshotPath) return
        
        deleteProc.exec(["rm", lastScreenshotPath])
    }
    
    Process {
        id: deleteProc
        onExited: code => {
            if (code === 0) {
                QsServices.Logger.info("Screenshot", `Deleted: ${root.lastScreenshotPath}`)
                root.lastScreenshotPath = ""
            }
        }
    }
}
