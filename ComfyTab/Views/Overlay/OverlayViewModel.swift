//
//  OverlayViewModel.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import SwiftUI
import Combine

enum OverlayState {
    case homeView
    case configureVibe
    case goWithFlow
}

class OverlayViewModel: ObservableObject {
    @Published var isPinned: Bool = false
    
    var lastState: OverlayState? = nil
    @Published var overlayState : OverlayState = .homeView
    @Published var isShowing: Bool = false
    
    @Published var comfyTabSize: (radius: CGFloat, thickness: CGFloat) = (130, 80)
    
    var runningAppManager: RunningAppManager
    var settingsManager  : SettingsManager
    
    @Published var allRunningApps: [RunningApp] = []
    /// Filtered List of Apps
    @Published var runningApps: [RunningApp] = []
    /// List of All Hidden Apps We Add To
    @Published var hiddenApps: Set<RunningApp> = []
    
    init(
        overlayState: OverlayState = .homeView,
        runningAppManager: RunningAppManager,
        settingsManager: SettingsManager
    ) {
        self.overlayState = overlayState
        self.runningAppManager = runningAppManager
        self.settingsManager = settingsManager
    }
    
    // MARK: - Pin Toggle
    public func togglePinned() {
        isPinned.toggle()
    }
    
    // MARK: - State Functions
    public func switchOverlayState(to state: OverlayState) {
        self.lastState = self.overlayState
        self.overlayState = state
        
        if overlayState == .homeView {
            self.lastState = nil
        }
    }
    
    public func goBack() {
        guard let lastState = lastState else { return }
        self.overlayState = lastState
        self.lastState = nil
    }
    
    public func getRunningApps() {
        
        if settingsManager.isIntroAnimationEnabled {
            // Clear first to ensure animation triggers
            self.runningApps = []
        }
        
        Task { [weak self] in
            guard let self else { return }
            await runningAppManager.getRunningApps { apps in
                self.allRunningApps = apps  /// we use this to filter
                var unFilteredApps = apps
                unFilteredApps.removeAll { self.hiddenApps.contains($0) }
                
                self.runningApps = unFilteredApps
                print("got Running App \(self.runningApps.count)")
            }
        }
    }
    
    public func focusApp(index: Int)  {
        self.runningAppManager.goToApp(runningApps[index])
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
}
