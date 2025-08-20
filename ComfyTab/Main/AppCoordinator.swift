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
        /// Init Default Managers
        self.settingsManager     = SettingsManager()
        self.runningAppManager   = RunningAppManager()
        self.permissionManager   = PermissionManager()
        self.installedAppManager = InstalledAppManager(
            settingsManager: settingsManager
        )

        /// Init The Overlay
        self.overlay             = Overlay(
            runningAppManager: runningAppManager,
            settingsManager  : settingsManager
        )
        
        /// init HotkeyManager
        self.hotkeyManager     = HotkeyManager(
            settingsManager  : settingsManager,
            overlay          : overlay,
            overlayViewModel : overlay.overlayViewModel
        )
    }
    
    deinit {}
    
    func prepare() {
        /// Call Once At The Start to Cache
        overlay.overlayViewModel.getRunningApps()
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
