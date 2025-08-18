//
//  AppCoordinator.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import Combine

/// we make it observable so we can pass it around as a enviorment object
final class AppCoordinator : ObservableObject {
    var settingsManager     : SettingsManager
    let permissionManager   : PermissionManager
    let hotkeyManager       : HotkeyManager
    let overlay             : Overlay
    
    let runningAppManager   : RunningAppManager
    let installedAppManager : InstalledAppManager
    
    var cancellables = Set<AnyCancellable>()
    var didStart = false
    
    init() {
        self.settingsManager     = SettingsManager()
        self.runningAppManager   = RunningAppManager()
        self.permissionManager   = PermissionManager()
        self.overlay             = Overlay(
            runningAppManager: runningAppManager,
            settingsManager  : settingsManager
        )
        self.installedAppManager = InstalledAppManager()
        
        /// init HotkeyManager
        self.hotkeyManager     = HotkeyManager(
            settingsManager  : settingsManager,
            permissionManager: permissionManager,
            overlay          : overlay,
            overlayViewModel : overlay.overlayViewModel
        )
    }
    
    deinit {
        
    }
    
    func prepare() {
        /// In The Past We Used CGEvent, to listen for events, now we use Carbon so its registed, we dont need
        /// permissions for the UI to show up
        hotkeyManager.setupHotkey()
        start()
    }
    
    func start() {
        guard !didStart else { return }
        didStart = true
    }
}
