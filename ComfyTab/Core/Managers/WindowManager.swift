//
//  WindowManager.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/27/25.
//

import Combine
import Foundation
import CoreGraphics
import ScreenCaptureKit

struct WindowInfo {
    var name: String
    var count: Int
    var windowIDs: [CGWindowID]
    var scWindows: [SCWindow]?
    var image: CGImage?
}

struct RunningAppInfo: Hashable {
    let name: String
    let bundleID: String?
    let pid: pid_t
}

let ignoreList: [String] = [
    "loginwindow",
    "Window Server",
    "Spotlight",
    "Universal Control",
    "AutoFill",
    "CursorUIViewService",
    "ThemeWidgetControlViewService",
    "nsattributedstringagent",
    "Open and Save Panel Service"
]

/// WindowManager For Apps That Are Open
class WindowManager: ObservableObject {
    init() {
        /// Keeping Init Emtpy
    }
    
    func getRunningAppsWithWindows() -> [RunningAppInfo] {
        let windowListInfo = CGWindowListCopyWindowInfo([.excludeDesktopElements], kCGNullWindowID) as? [[String: AnyObject]] ?? []
        
        var seenPIDs = Set<pid_t>()
        
        for windowInfo in windowListInfo {
            guard let pid = windowInfo[kCGWindowOwnerPID as String] as? pid_t,
                  let alpha = windowInfo[kCGWindowAlpha as String] as? CGFloat,
                  let layer = windowInfo[kCGWindowLayer as String] as? Int,
                  let bounds = windowInfo[kCGWindowBounds as String] as? [String: Any],
                  let width = bounds["Width"] as? CGFloat,
                  let height = bounds["Height"] as? CGFloat
            else { continue }
            
            if alpha > 0.0, layer == 0, width > 50, height > 50 {
                seenPIDs.insert(pid)
            }
        }
        
        let runningApps = NSWorkspace.shared.runningApplications
        let filteredApps: [RunningAppInfo] = runningApps.compactMap { app in
            guard seenPIDs.contains(app.processIdentifier), let name = app.localizedName else { return nil }
            guard ignoreList.contains(name) == false else { return nil }
            return RunningAppInfo(name: name, bundleID: app.bundleIdentifier, pid: app.processIdentifier)
        }
        
        return filteredApps
    }
    
    func getOpenAppWindowCounts() async -> [WindowInfo] {
        let windowListInfo = CGWindowListCopyWindowInfo([.excludeDesktopElements], kCGNullWindowID) as? [[String: AnyObject]] ?? []
        
        var appWindowMap: [String: WindowInfo] = [:]
        var seenWindows: Set<String> = []
        
        for windowInfo in windowListInfo {
            guard let ownerName = windowInfo[kCGWindowOwnerName as String] as? String,
                  let windowAlpha = windowInfo[kCGWindowAlpha as String] as? CGFloat,
                  let windowID = windowInfo[kCGWindowNumber as String] as? CGWindowID,
                  let layer = windowInfo[kCGWindowLayer as String] as? Int,
                  let bounds = windowInfo[kCGWindowBounds as String] as? [String: Any],
                  let width = bounds["Width"] as? CGFloat, width > 50,
                  let height = bounds["Height"] as? CGFloat, height > 50,
                  let pid = windowInfo[kCGWindowOwnerPID as String] as? Int else {
                continue
            }
            
            // Uniqueness key: combine PID + window title
            let title = (windowInfo[kCGWindowName as String] as? String) ?? ""
            let windowKey = "\(pid)-\(title)"
            
            // Skip duplicate logical windows
            if seenWindows.contains(windowKey) { continue }
            seenWindows.insert(windowKey)
            
            // Skip ignored apps
            guard !ownerName.isEmpty else { continue }
            if ignoreList.contains(where: { $0.caseInsensitiveCompare(ownerName) == .orderedSame }) {
                continue
            }
            
            // Track window
            if appWindowMap[ownerName] == nil {
                appWindowMap[ownerName] = WindowInfo(name: ownerName, count: 1, windowIDs: [windowID])
            } else {
                appWindowMap[ownerName]!.count += 1
                appWindowMap[ownerName]!.windowIDs.append(windowID)
            }
        }
        
        return await attachSCWindows(to: appWindowMap.values.sorted(by: { $0.count > $1.count }))
    }
    
//    func getOpenAppWindowCounts() async -> [WindowInfo] {
//        let windowListInfo = CGWindowListCopyWindowInfo([.excludeDesktopElements], kCGNullWindowID) as? [[String: AnyObject]] ?? []
//        
//        var appWindowMap: [String: WindowInfo] = [:]
//
//        for windowInfo in windowListInfo {
//            guard let ownerName = windowInfo[kCGWindowOwnerName as String] as? String,
//                  let windowAlpha = windowInfo[kCGWindowAlpha as String] as? CGFloat,
//                  let windowID = windowInfo[kCGWindowNumber as String] as? CGWindowID,
//                  let layer = windowInfo[kCGWindowLayer as String] as? Int else {
//                continue
//            }
//            
//            if windowAlpha > 0 && layer == 0,
//               let bounds = windowInfo[kCGWindowBounds as String] as? [String: Any],
//               let width = bounds["Width"] as? CGFloat, width > 50,
//               let height = bounds["Height"] as? CGFloat, height > 50 {
//                /*let isOnScreen = windowInfo[kCGWindowIsOnscreen as String] as? Bool, isOnScreen*/
//                    
//
//                
//                guard !ownerName.isEmpty else { continue }
//                if ignoreList.contains(where: { $0.caseInsensitiveCompare(ownerName) == .orderedSame }) {
//                    continue
//                }
//                if appWindowMap[ownerName] == nil {
//                    appWindowMap[ownerName] = WindowInfo(name: ownerName, count: 1, windowIDs: [windowID])
//                } else {
//                    appWindowMap[ownerName]!.count += 1
//                    appWindowMap[ownerName]!.windowIDs.append(windowID)
//                }
//            }
//        }
//        
//        return await attachSCWindows(
//            to: appWindowMap.values.sorted(by: {
//                $0.count > $1.count
//            })
//        )
//    }

    
    func attachSCWindows(to coreWindows: [WindowInfo]) async -> [WindowInfo] {
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)
            
            var mapped = coreWindows
            
            for i in mapped.indices {
                let ids = Set(mapped[i].windowIDs.map { $0 as UInt32 })
                let matchedSCWindows = content.windows.filter { ids.contains($0.windowID) }
                mapped[i].scWindows = matchedSCWindows
                
//                if !matchedSCWindows.isEmpty {
//                    mapped[i].image = await captureAppScreenshot(windows: matchedSCWindows, appName: mapped[i].name)
//                }
            }
            
            return mapped
        } catch {
            print("❌ Failed to merge SCWindows: \(error)")
            return coreWindows
        }
    }
    
    func captureAppScreenshot(windows: [SCWindow], appName: String) async -> CGImage? {
        // Sort windows by area (largest first) and try to capture them
        let sortedWindows = windows.sorted { window1, window2 in
            let area1 = window1.frame.width * window1.frame.height
            let area2 = window2.frame.width * window2.frame.height
            return area1 > area2
        }
        
        print("🔍 Trying to capture \(sortedWindows.count) windows for \(appName)")
        
        for (index, window) in sortedWindows.enumerated() {
            print("   Attempt \(index + 1): Window \(window.windowID) (\(Int(window.frame.width))x\(Int(window.frame.height)))")
            if let screenshot = await captureWindowScreenshot(window: window) {
                print("✅ Successfully captured screenshot for \(appName) (window \(window.windowID))")
                return screenshot
            }
        }
        
        print("⚠️ Failed to capture any screenshots for \(appName)")
        return nil
    }
    
    /// Capture screenshot of a specific SCWindow
    func captureWindowScreenshot(window: SCWindow) async -> CGImage? {
        do {
            // Validate window dimensions
            let windowWidth = window.frame.width
            let windowHeight = window.frame.height
            
            // Skip windows that are too small or have invalid dimensions
            guard windowWidth > 0 && windowHeight > 0 && windowWidth < 10000 && windowHeight < 10000 else {
                print("⚠️ Skipping window \(window.windowID) with invalid dimensions: \(windowWidth)x\(windowHeight)")
                return nil
            }
            
            // Only skip if window is actually minimized (not just off-screen)
            // Note: There's no direct minimized property in SCWindow, so we'll try to capture everything
            
            let filter = SCContentFilter(desktopIndependentWindow: window)
            let configuration = SCStreamConfiguration()
            
            // Set validated dimensions with reasonable limits
            configuration.width = min(Int(windowWidth), 2000)  // Cap at 2000px width
            configuration.height = min(Int(windowHeight), 2000) // Cap at 2000px height
            configuration.capturesAudio = false
            configuration.showsCursor = false
            configuration.backgroundColor = .clear
            
            // Use a small delay to ensure window is ready
            try await Task.sleep(nanoseconds: 10_000_000) // 10ms
            
            let image = try await SCScreenshotManager.captureImage(
                contentFilter: filter,
                configuration: configuration
            )
            
            print("✅ Successfully captured window \(window.windowID) (\(Int(windowWidth))x\(Int(windowHeight)))")
            return image
        } catch {
            print("❌ Failed to capture screenshot for window \(window.windowID): \(error)")
            return nil
        }
    }
    
    /// Capture screenshot of all windows for a specific app
    func captureAllWindowsForApp(appName: String) async -> [CGImage] {
        let windows = await getOpenAppWindowCounts()
        guard let appInfo = windows.first(where: { $0.name == appName }),
              let scWindows = appInfo.scWindows else {
            return []
        }
        
        var screenshots: [CGImage] = []
        print("📸 Capturing ALL windows for \(appName) (\(scWindows.count) windows)")
        
        for (index, window) in scWindows.enumerated() {
            print("   Processing window \(index + 1)/\(scWindows.count): \(window.windowID)")
            if let screenshot = await captureWindowScreenshot(window: window) {
                screenshots.append(screenshot)
            }
        }
        
        print("✅ Captured \(screenshots.count)/\(scWindows.count) screenshots for \(appName)")
        return screenshots
    }
}

