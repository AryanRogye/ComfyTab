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
    
    @Published var runningApps: [RunningApp] = []
    
    init(overlayState: OverlayState = .homeView, runningAppManager: RunningAppManager, settingsManager: SettingsManager) {
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
        runningAppManager.getRunningApps { apps in
            DispatchQueue.main.async {
                self.runningApps = apps
            }
        }
    }
    
    public func focusApp(index: Int)  {
        self.runningAppManager.goToApp(runningApps[index])
    }
}
