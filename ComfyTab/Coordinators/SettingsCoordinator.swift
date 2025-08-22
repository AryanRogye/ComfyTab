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
    
    let deps: AppEnv
    
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
            size: NSSize(width: 800, height: 500)
        )
    }
}
