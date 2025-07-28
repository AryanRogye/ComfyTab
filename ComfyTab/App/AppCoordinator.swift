//
//  AppCoordinator.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import Combine


final class AppCoordinator {
    let permissionManager : PermissionManager
    let hotkeyManager     : HotkeyManager
    let overlay           : Overlay
    
    var cancellables = Set<AnyCancellable>()
    var didStart = false

    init() {
        self.permissionManager = PermissionManager()
        self.overlay = Overlay()
        self.hotkeyManager = HotkeyManager(
            permissionManager: permissionManager,
            overlay          : overlay
        )
    }
    
    deinit {
        
    }
    
    func prepare() {
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
