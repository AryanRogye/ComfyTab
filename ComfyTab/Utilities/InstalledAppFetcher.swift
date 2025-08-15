//
//  InstalledAppFetcher.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import Foundation
import AppKit

struct InstalledApp: Hashable {
    let url: URL
    let name: String
    let image: NSImage?
}

class InstalledAppFetcher {
    let appDirs = [
        "/Applications",
        "/System/Applications",
        "\(NSHomeDirectory())/Applications"
    ]
    
    func fetchApps() -> [InstalledApp] {
        var installedApps : [InstalledApp] = []
        
        for dir in appDirs {
            let dirURL = URL(fileURLWithPath: dir)
            if let urls = try? FileManager.default.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) {
                installedApps += urls.compactMap { url in
                    guard url.pathExtension == "app" else { return nil }
                    return InstalledApp(
                        url: url,
                        name: getAppName(from: url),
                        image: getAppIcon(from: url))
                }
            }
        }
        
        return installedApps
    }
    
    func getAppName(from url: URL) -> String {
        let infoPlistURL = url.appendingPathComponent("Contents/Info.plist")
        
        if let info = NSDictionary(contentsOf: infoPlistURL),
           let displayName = info["CFBundleDisplayName"] as? String ?? info["CFBundleName"] as? String {
            return displayName
        }
        
        return url.deletingPathExtension().lastPathComponent
    }
    
    func getAppIcon(from url: URL) -> NSImage? {
        let infoPlistURL = url.appendingPathComponent("Contents/Info.plist")
        var iconFileName = "Icon"
        if let info = NSDictionary(contentsOf: infoPlistURL),
           let iconName = info["CFBundleIconFile"] as? String {
            iconFileName = iconName
        }
        // .icns extension may not be included in the plist
        if !iconFileName.hasSuffix(".icns") {
            iconFileName += ".icns"
        }
        let iconURL = url.appendingPathComponent("Contents/Resources/\(iconFileName)")
        return NSImage(contentsOfFile: iconURL.path)
    }
}
