//
//  OverlayViewModel.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import SwiftUI
import Combine

class OverlayViewModel: ObservableObject {
    @Published var isPinned: Bool = false
    
    @Published var isShowing: Bool = false
    
    @Published var comfyTabSize: (radius: CGFloat, thickness: CGFloat) = (130, 80)
    
    var runningAppManager: RunningAppManager
    var settingsManager  : SettingsManager
    
    /// All Running Apps, this is nice when we wanna display the currently running apps
    @Published var allRunningApps: [RunningApp] = []
    /// Filtered List of Apps
    @Published var runningApps: [RunningApp] = []
    /// List of All Hidden Apps We Add To
    @Published var hiddenApps: Set<RunningApp> = []
    @Published var closeOnFinderOpen: Bool = false
    
    private var overlay: Overlay

    init(
        runningAppManager: RunningAppManager,
        settingsManager: SettingsManager,
        overlay: Overlay
    ) {
        self.runningAppManager = runningAppManager
        self.settingsManager = settingsManager
        self.overlay = overlay
    }
    
    // MARK: - Public Utilities
    /// toggles the state of the pin, Hotkey Listens for this value
    public func togglePinned() {
        isPinned.toggle()
    }
    /// Forces if Pinned, to close, this is nice, when finder is opened to close it
    public func onFinderOpen(_ app: RunningApp) {
        app.revealInFinder()
        overlay.hide()
    }
    /// Nice Utility Function to Focus the App, Called when we click from the Dial
    public func focusApp(index: Int)  {
        self.runningAppManager.goToApp(runningApps[index])
        overlay.hide()
    }

    // MARK: - Running Apps
    /// Function Gets the Running Apps For The User
    public func getRunningApps() {
        
        /// if Intro is Enabled we clear to show a nice animation of filling
        if settingsManager.isIntroAnimationEnabled {
            // Clear first to ensure animation triggers
            self.runningApps = []
        }
        
        Task { [weak self] in
            guard let self else { return }
            await runningAppManager.getRunningApps { apps in
                self.allRunningApps = apps // this cant be filtered
                
                // 1) Build a fast lookup for hidden apps (by pid OR bundleID)
                let hiddenPIDs: Set<pid_t> = Set(self.hiddenApps.map { $0.pid })
                let hiddenBundleIDs: Set<String> = Set(self.hiddenApps.compactMap { $0.bundleID })
                
                // 2) Filter out hidden apps using stable identity
                let filtered = apps.filter { app in
                    if hiddenPIDs.contains(app.pid) { return false }
                    if let bid = app.bundleID, hiddenBundleIDs.contains(bid) { return false }
                    return true
                }
                
                // 3) De-dupe by pid (keeps first occurrence, preserves order)
                var seen = Set<pid_t>(minimumCapacity: filtered.count)
                var result: [RunningApp] = []
                result.reserveCapacity(filtered.count)
                
                for app in filtered {
                    if seen.insert(app.pid).inserted {
                        result.append(app)
                    }
                }
                
                self.runningApps = result
            }
        }
    }
    
    
    // MARK: - Hidden App Stuff
    public func addHiddenApp(_ isOn: Bool,for app: RunningApp) {
        if isOn {
            hiddenApps.insert(app)
            self.runningApps.removeAll { $0 == app }
            Task { [weak self] in
                guard let self else { return }
                /// we just remove it so the UI updates
                await self.runningAppManager.removeFromCache(app)
            }
        } else {
            hiddenApps.remove(app)
            if allRunningApps.contains(app) {
                self.runningApps.append(app)
            }
            Task { [weak self] in
                guard let self else { return }
                
                /// if All The Running Apps has the app we want, just add it in
                
                await self.runningAppManager.addToCache(app)
            }
        }
    }
    
    private func loadHiddenItems() {
        
    }
}
