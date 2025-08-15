//
//  RunningAppManager.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/14/25.
//

import SwiftUI
import Combine

class RunningAppManager: ObservableObject {
    
    var runningApps: [RunningApp] = []
    
    public func getRunningApps() {
        do {
            self.runningApps = try RunningAppFetcher.fetchRunningApps()
            print("Fetched running apps: \(runningApps.count)")
        } catch {
            print("There Was A Error Fetching Running Apps: \(error)")
        }
    }
}
