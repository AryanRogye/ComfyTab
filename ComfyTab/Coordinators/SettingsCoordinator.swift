//
//  SettingsCoordinator.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/21/25.
//

import SwiftUI

@MainActor
class SettingsCoordinator {
    
    let windowCoordinator: WindowCoordinator
    
    let settingsViewModel : SettingsViewModel
    let behaviorViewModel : BehaviorViewModel
    let generalViewModel  : GeneralViewModel
    let permissionViewModel : PermissionViewModel
    
    var deps: AppEnv
    
    init(windows: WindowCoordinator, deps: AppEnv) {
        self.windowCoordinator = windows
        self.deps = deps
        self.settingsViewModel = SettingsViewModel(deps: deps)
        self.behaviorViewModel = BehaviorViewModel(deps: deps)
        self.generalViewModel  = GeneralViewModel(deps: deps)
        self.permissionViewModel = PermissionViewModel(deps: deps)
    }
    
    func showSettings() {
        
        let view = SettingsView()
            .environmentObject(settingsViewModel)
            .environmentObject(behaviorViewModel)
            .environmentObject(generalViewModel)
            .environmentObject(permissionViewModel)
        
        windowCoordinator.showWindow(
            id: "settings",
            title: "Settings",
            content: view,
            size: NSSize(width: 800, height: 500),
            onOpen: {
                NSApp.activate(ignoringOtherApps: true)
                self.settingsViewModel.settingsService.isSettingsWindowOpen = true
                print("Settings Window Opened")
            },
            onClose: {
                self.settingsViewModel.settingsService.isSettingsWindowOpen = false
                NSApp.activate(ignoringOtherApps: false)
                print("Settings Window Closed")
            })
        
    }
}
