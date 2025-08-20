//
//  RunningAppFetcher.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/14/25.
//

import Foundation
import AppKit

struct RunningAppFetcher {
    
    // MARK: - Public API's
    /// Get all running applications
    public static func fetchRunningApps(
        cache: [RunningApp]
    ) throws -> [RunningApp] {
        
        let cacheByPID = Dictionary(uniqueKeysWithValues: cache.map { ($0.pid, $0) })
        var newList : [RunningApp] = []
        
        for app in NSWorkspace.shared.runningApplications {
            
            guard app.activationPolicy == .regular else { continue }
            
            let name = app.localizedName ?? ""
            let hidden = app.isHidden
            let isTerminated = app.isTerminated
            let pid = app.processIdentifier
            let bundleID = app.bundleIdentifier
            
            if var cached = cacheByPID[pid] {
                // Refresh cheap, frequently-changing fields
                cached.hidden       = app.isHidden
                cached.isTerminated = app.isTerminated
                
                // Opportunistic refreshes
                if cached.name != name { cached.name = name }
                if cached.bundleID != bundleID { cached.bundleID = bundleID }
                
                newList.append(cached)
            } else {
                newList.append(
                    RunningApp(
                        name: name,
                        hidden: hidden,
                        isTerminated: isTerminated,
                        bundleID: bundleID,
                        pid: pid,
                        url: app.bundleURL
                    )
                )
            }
        }
        
        let order = Dictionary(uniqueKeysWithValues: cache.enumerated().map { ($0.element.pid, $0.offset) })
        newList.sort { (a, b) in
            let ia = order[a.pid] ?? Int.max
            let ib = order[b.pid] ?? Int.max
            if ia != ib { return ia < ib }
            return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
        }
        
        return newList
    }
}
