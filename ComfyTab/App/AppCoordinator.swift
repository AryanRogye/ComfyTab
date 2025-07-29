//
//  AppCoordinator.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import Combine


final class AppCoordinator {
    let permissionManager   : PermissionManager
    let hotkeyManager       : HotkeyManager
    let overlay             : Overlay
    let windowManager       : WindowManager
    let installedAppManager : InstalledAppManager
    
    var cancellables = Set<AnyCancellable>()
    var didStart = false

    init() {
        self.permissionManager = PermissionManager()
        self.windowManager     = WindowManager()
        self.overlay           = Overlay(windowManager: windowManager)
        self.installedAppManager = InstalledAppManager()
        
        /// init HotkeyManager
        self.hotkeyManager     = HotkeyManager(
                permissionManager: permissionManager,
                overlay          : overlay
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
