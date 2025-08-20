//
//  AppIconManager.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/19/25.
//

import SwiftUI
import UniformTypeIdentifiers

@MainActor
struct AppIconManager {
    /// hashmap of our BundleID : AppIcons
    /// This is cuz NSImage is a AppKit/SwiftUI DataType Only gonna run on the MainActor
    /// NSImage is Sendable 🙄
    @MainActor
    private(set) static var appIcons: [String: NSImage] = [:]
    
    /// Loading Tasks to prevent duplicate loads
    @MainActor
    private static var loadingTasks: [String: [(NSImage) -> Void]] = [:]
    
    /// Nice Function to remove app icons from the cache
    @MainActor
    public static func removeAppIcon(for bundleID: String) {
        appIcons.removeValue(forKey: bundleID)
    }
    
    /// Loads app icon into the cache
    @MainActor
    public static func loadAppIcon(
        for url: URL? = nil,
        bundleID: String,
        completion: @escaping (NSImage) -> Void
    ) {
        /// If We Have A Cached Icon, we Return it right away
        if let cached = appIcons[bundleID] {
            completion(cached)
            return
        }
        
        /// If we already have a loading task for this bundleID, we just add the completion to the queue
        if loadingTasks[bundleID] != nil {
            /// This kinda tells us that "hey we are already loading this icon, so just append so later we can update it"
            /// You Can see this later in the `callbacks?.forEach { $0(icon) `
            loadingTasks[bundleID]?.append(completion)
            return
        }
        
        /// If No Loading Task Exists, we create one
        loadingTasks[bundleID] = [completion]
        
        /// Get the icon
        let icon = performIconLoad(
            for: url,
            bundleID: bundleID,
        )
        /// Set it
        appIcons[bundleID] = icon
        
        // Call all pending callbacks
        let callbacks = loadingTasks.removeValue(forKey: bundleID)
        /// We call all the callbacks that were waiting for this icon to load
        callbacks?.forEach{ $0(icon) }
    }
}

extension AppIconManager {
    /// Actual Perform Loading Of the Icon
    @MainActor
    private static func performIconLoad(
        for url: URL?,
        bundleID: String,
    ) -> NSImage {
        /// Many Steps We Can Take To Get the App Icon Fast
        
        /// 1. If User Provided a URL
        if let url = url {
            return icon_URL(url, bundleID)
        }
        
        /// 2. NSRunningApplication
        if let running = icon_RunningApplication(bundleID) {
            return running
        }
        
        // 3) Launch Services lookup by bundle id
        if let launchServices = icon_LaunchServices(bundleID) {
            return launchServices
        }
        
        /// 4. If Nothing Works we fallback to the default icon
        return fallbackAppIcon()
    }
    
    
    // MARK: - Helpers
    
    /// Get Icon URL if its in Launch Services
    @MainActor
    private static func icon_LaunchServices(
        _ bundleID: String,
    ) -> NSImage? {
        if let cfURLs = LSCopyApplicationURLsForBundleIdentifier(bundleID as CFString, nil)?.takeRetainedValue() as? [URL],
           let url = cfURLs.first {
            return normalizeIcon(forFile: url.path)
        }
        return nil
    }
    
    /// Get Icon URL if Its in Running Applications
    @MainActor
    private static func icon_RunningApplication(
        _ bundleID: String,
    ) -> NSImage? {
        if let running = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).first {
            if let img = running.icon {
                return img
            }
            if let bundleURL = running.bundleURL {
                return normalizeIcon(forFile: bundleURL.path)
            }
        }
        return nil
    }
    
    /// Get Icon URL with a URL
    @MainActor
    private static func icon_URL(
        _ url: URL,
        _ bundleID: String,
    ) -> NSImage {
        return normalizeIcon(forFile: url.path)
    }
    
    /// Function to normalize the icon
    @MainActor
    private static func normalizeIcon(forFile file: String) -> NSImage {
        let icon = NSWorkspace.shared.icon(forFile: file)
        icon.isTemplate = false
        return icon
    }
    
    
    /// Function to get the fallback icon, this is what we use internally
    @MainActor
    public static func fallbackAppIcon() -> NSImage {
        let icon: NSImage
        if #available(macOS 12.0, *) {
            icon = NSWorkspace.shared.icon(for: .applicationBundle)
        } else {
            icon = NSWorkspace.shared.icon(forFileType: "app")
        }
        return icon
    }
}
