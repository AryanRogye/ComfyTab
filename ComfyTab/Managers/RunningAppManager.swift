//
//  RunningAppManager.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/14/25.
//

import SwiftUI

final actor RunningAppManager: RunningAppService {
    
    /// Cache Of Running Apps
    private(set) var runningApps: [RunningApp] = []
    
    public func snapshot() async -> [RunningApp] {
        return runningApps
    }
    
    // MARK: - Observe Running Apps
    public func observe() -> AsyncStream<[RunningApp]> {
        AsyncStream(bufferingPolicy: .bufferingNewest(1)) { cont in
            /// Emit First Snapshot
            /// Needs @MainActor Explicit for running Apps idk why its not inferred
            /// Can make 1 just dont want to
            Task { @MainActor in
                let cached = await self.runningApps
                cont.yield(cached)
            }
            Task {
                let fresh = await self.snapshotAndUpdateCache()
                cont.yield(fresh)
            }
            
            // workspace notifications → re-snapshot + emit
            let nc = NSWorkspace.shared.notificationCenter
            let toks = [
                nc.addObserver(forName: NSWorkspace.didLaunchApplicationNotification, object: nil, queue: nil) { _ in
                    Task {
                        let next = await self.snapshotAndUpdateCache()
                        cont.yield(next)
                    }
                },
                nc.addObserver(forName: NSWorkspace.didTerminateApplicationNotification, object: nil, queue: nil) { _ in
                    Task {
                        let next = await self.snapshotAndUpdateCache()
                        cont.yield(next)
                    }
                },
                nc.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: nil) { _ in
                    Task {
                        let next = await self.snapshotAndUpdateCache()
                        cont.yield(next)
                    }
                }
            ]
            cont.onTermination = { _ in toks.forEach(nc.removeObserver) }
        }
    }
    
    // MARK: - Remove From Cache
    public func removeFromCache(_ app: RunningApp) async {
        runningApps.removeAll {
            $0 == app
        }
    }
    
    
    // MARK: - Go To App
    nonisolated public func goToApp(_ runningApp: RunningApp) {
        runningApp.focusApp()
    }
    
    // MARK: - Snapshot and Update Cache
    private func snapshotAndUpdateCache() async -> [RunningApp] {
        let cacheByPID = Dictionary(uniqueKeysWithValues: runningApps.map { ($0.pid, $0) })
        var newList : [RunningApp] = []
        /// Loop Through Running Apps Provided By NSWorkspace
        for app in NSWorkspace.shared.runningApplications {
            
            /// Make sure the app is a regular app (not a background app)
            guard app.activationPolicy == .regular else { continue }
            
            /// Values to create a RunningApp instance
            let name = app.localizedName ?? ""
            let hidden = app.isHidden
            let isTerminated = app.isTerminated
            let pid = app.processIdentifier
            let bundleID = app.bundleIdentifier
            
            /// Create RunningApp Instance if not Cached At SnapShot
            if var cached = cacheByPID[pid] {
                // Refresh cheap, frequently-changing fields
                cached.hidden       = app.isHidden
                cached.isTerminated = app.isTerminated
                
                // Opportunistic refreshes
                if cached.name != name { cached.name = name }
                if cached.bundleID != bundleID { cached.bundleID = bundleID }
                
                /// Create a New Instance to send back
                newList.append(RunningApp(
                    name: cached.name,
                    hidden: cached.hidden,
                    isTerminated: cached.isTerminated,
                    bundleID: cached.bundleID,
                    pid: cached.pid,
                    url: app.bundleURL
                ))
            } else {
                
                /// Send Back A Copy
                newList.append(RunningApp(
                    name: name,
                    hidden: hidden,
                    isTerminated: isTerminated,
                    bundleID: bundleID,
                    pid: pid,
                    url: app.bundleURL
                ))
            }
        }
        
        let order = Dictionary(uniqueKeysWithValues: runningApps.enumerated().map { ($0.element.pid, $0.offset) })
        newList.sort { (a, b) in
            let ia = order[a.pid] ?? Int.max
            let ib = order[b.pid] ?? Int.max
            if ia != ib { return ia < ib }
            return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
        }
        
        runningApps = newList
        return runningApps
    }
}
