//
//  RunningAppManager.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/14/25.
//

import SwiftUI

final class RunningAppManager {
    
    private(set) var runningApps: [RunningApp] = []
    private(set) var fetchEpoch = 0   // cancels stale inflight fetches
    
    func getRunningApps(
        completion: @escaping ([RunningApp]) -> Void
    ) {
        /// Send Cached Copy At The Start
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            completion(self.runningApps)
        }
        
        var epochSnapshot = 0
        var cacheSnapshot: [RunningApp] = []
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            fetchEpoch &+= 1
            epochSnapshot = self.fetchEpoch
            cacheSnapshot = self.runningApps /// Immutable Copy
        }
        
        /// Hop on A Different Thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            do {
                let fresh = try RunningAppFetcher.fetchRunningApps(
                    cache: cacheSnapshot
                )
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    // Bail if a newer fetch started
                    /// Keep a internal copy for later caching
                    guard epochSnapshot == self.fetchEpoch else { return }
                    if fresh != self.runningApps {
                        self.runningApps = fresh
                        completion(fresh)
                    }
                }
            } catch {
                print("There Was A Error Fetching Running Apps: \(error)")
                DispatchQueue.main.async {
                    completion(self.runningApps) // return the previous list
                }
            }
        }
    }
    
    public func goToApp(_ runningApp: RunningApp) {
        runningApp.focusApp()
    }
}
