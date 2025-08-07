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
    
    var windowManager: WindowManager
    
    @Published var chosenApps: [RunningAppInfo] = []
    @Published var runningApps: [RunningAppInfo]? = nil
    @Published var allApps: [RunningAppInfo]? = nil
    @Published var overlay: (width: CGFloat, height: CGFloat) = (200,200)
    @Published var isShowing: Bool = false
    
    init(overlayState: OverlayState = .homeView, windowManager: WindowManager) {
        self.overlayState = overlayState
        self.windowManager = windowManager
        
        /// Get Open Running Apps
        runningApps = getOpenApps()
        
        /// Assign Chosen Apps
        chosenApps = runningApps ?? []
        
        /// No Need to get non_running_apps
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
    
    // MARK: - Window Management
    public func syncRunningApps() {
        self.runningApps = getOpenApps()
    }
    private func getOpenApps() -> [RunningAppInfo] {
        return windowManager.getRunningAppsWithWindows()
    }
    
    public func switchTab(_ tab: RunningAppInfo) {
        if let app = NSRunningApplication(processIdentifier: tab.pid) {
            app.activate(options: [.activateAllWindows])
        }
    }
}
