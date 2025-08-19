//
//  InstalledAppFetcher.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import AppKit
import UniformTypeIdentifiers

final class InstalledAppFetcher {
    
    static func fetchApps(
        from directoryOfApps: [URL],
        timeout: TimeInterval = 1.5
    ) -> [InstalledApp] {
        
        let fm = FileManager.default
        let keys: Set<URLResourceKey> = [.contentTypeKey, .localizedNameKey]
        
        var results : [InstalledApp] = []
        
        for root in directoryOfApps where fm.fileExists(atPath: root.path) {
            guard let e = fm.enumerator(
                at: root,
                includingPropertiesForKeys: Array(keys),
                options: [.skipsHiddenFiles, .skipsPackageDescendants]
            ) else { continue }
            
            for case let url as URL in e {
                // Only keep .app bundles
                guard (try? url.resourceValues(forKeys: keys))?
                    .contentType?
                    .conforms(to: .applicationBundle) == true
                else { continue }
                
                let bundle = Bundle(url: url)
                
                let name = (try? url.resourceValues(forKeys: [.localizedNameKey]))?.localizedName
                ?? bundle?.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
                ?? bundle?.object(forInfoDictionaryKey: "CFBundleName") as? String
                ?? url.deletingPathExtension().lastPathComponent
                
                let bundleID = bundle?.bundleIdentifier
                let pid = bundleID.flatMap {
                    NSRunningApplication.runningApplications(withBundleIdentifier: $0).first?.processIdentifier
                }
                
                results.append(InstalledApp(url: url, name: name, bundleID: bundleID))
            }
            
            var seen = Set<String>()
            return results.compactMap { app in
                let key = app.bundleID ?? app.url.path
                return seen.insert(key).inserted ? app : nil
            }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
        
        return []
    }
}
