//
//  RunningAppManager.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/14/25.
//

import SwiftUI

final actor RunningAppManager {
    
    private(set) var runningApps: [RunningApp] = []
    private(set) var fetchEpoch = 0   // cancels stale inflight fetches
    
    public func removeFromCache(_ app: RunningApp) {
        runningApps.removeAll {
            $0 == app
        }
    }
    
    public func addToCache(_ app: RunningApp) {
        if !runningApps.contains(app) {
            runningApps.append(app)
        }
    }
    
    /**
     NOTE:
        By adding @MainActor to the completion parameter, i'm telling the compiler that the
        completion handler must run on the main actor. This means I can eliminate explicit
        MainActor.run calls, didnt know that its sick, gonna leave it here as a note for me
     */
    func getRunningApps(
        completion: @MainActor @escaping ([RunningApp]) -> Void
    ) {
        
        let cached = runningApps
        /// Send Cached Copy At The Start so it looks like we have no delays
        Task { @MainActor in
            completion(cached)
        }
        
        fetchEpoch &+= 1
        
        /// Create Copies
        let epochSnapshot = self.fetchEpoch
        let cacheSnapshot = self.runningApps /// Immutable Copy
        
        Task.detached(priority: .userInitiated) { [epochSnapshot, cacheSnapshot] in
            do {
                
                /// Get Fresh Copy
                let fresh = try RunningAppFetcher.fetchRunningApps(
                    cache: cacheSnapshot
                )
                
                /// Get Back Updated
                let updated = await self.applyIfNewest(epoch: epochSnapshot, fresh: fresh)
                
                if let apps = updated {
                    await completion(apps)
                }

            } catch {
                // on error, just emit the current snapshot
                let prev = await self.runningApps
                await completion(prev)
            }
        }
    }
    
    private func applyIfNewest(epoch: Int, fresh: [RunningApp]) -> [RunningApp]? {
        guard epoch == fetchEpoch else { return nil }
        if fresh != runningApps {
            runningApps = fresh
        }
        // still allow a “second emission” if the caller expects it
        return fresh
    }
    
    nonisolated public func goToApp(_ runningApp: RunningApp) {
        runningApp.focusApp()
    }
}
