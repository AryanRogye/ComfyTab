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
        self.overlay             = Overlay(runningAppManager: runningAppManager)
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
        /// Once we detect accessibilty is started/enabled start the app
        permissionManager.$isAccessibilityEnabled
            .filter { $0 }
            .sink { [weak self] granted in
                guard let self = self else { return }
                if granted {
                    self.start()
                }
            }
            .store(in: &cancellables)
    }
    
    func start() {
        guard !didStart else { return }
        didStart = true
        
        print("Started App With Correct Permissions")
        
        hotkeyManager.setupHotkey()
    }
}
