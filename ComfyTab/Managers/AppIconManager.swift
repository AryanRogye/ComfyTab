//
//  AppIconManager.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/19/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct AppIconManager {
    
    /// hashmap of our BundleID : AppIcons
    /// This is cuz NSImage is a AppKit/SwiftUI DataType Only gonna run on the MainActor
    @MainActor
    public static var appIcons: [String: NSImage] = [:]
    
    /// Loads app icon into the cache
    @MainActor
    public static func loadAppIcon(
        for url: URL? = nil,
        bundleID: String,
        size: NSSize = NSSize(width: 64, height: 64)
    ) -> NSImage {
        if let icon = appIcons[bundleID] {
            return icon
        }
        print("No App Icon Found, Looking For New Icon for \(bundleID)")
        
        /// Many Steps We Can Take To Get the App Icon Fast
        
        /// 1. If User Provided a URL
        if let url = url {
            let icon = normalizeIcon(forFile: url.path, size: size)
            appIcons[bundleID] = icon
            return icon
        }
        
        /// 2. NSRunningApplication
        if let running = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).first {
            if let img = running.icon {
                appIcons[bundleID] = img
                return img
            }
            if let bundleURL = running.bundleURL {
                let icon = normalizeIcon(forFile: bundleURL.path, size: size)
                appIcons[bundleID] = icon
                return icon
            }
        }
        
        // 3) Launch Services lookup by bundle id
        if let cfURLs = LSCopyApplicationURLsForBundleIdentifier(bundleID as CFString, nil)?.takeRetainedValue() as? [URL],
           let url = cfURLs.first {
            let icon = normalizeIcon(forFile: url.path, size: size)
            appIcons[bundleID] = icon
            return icon
        }
        
        /// 4. If Nothing Works we fallback to the default icon
        let fallback = fallbackAppIcon(size: size)
        appIcons[bundleID] = fallback
        return fallback
    }
    
    // MARK: - Helpers
    
    /// Function to normalize the icon to a size
    @MainActor
    private static func normalizeIcon(forFile file: String, size: NSSize) -> NSImage {
        let icon = NSWorkspace.shared.icon(forFile: file)
        icon.size = size
        icon.isTemplate = false
        return icon
    }
    
    
    /// Function to get the fallback icon, this is what we use internally
    @MainActor
    private static func fallbackAppIcon(size: NSSize) -> NSImage {
        let icon: NSImage
        if #available(macOS 12.0, *) {
            icon = NSWorkspace.shared.icon(for: .applicationBundle)
        } else {
            icon = NSWorkspace.shared.icon(forFileType: "app")
        }
        icon.size = size
        return icon
    }
}
