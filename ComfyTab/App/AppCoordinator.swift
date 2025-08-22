//
//  AppCoordinator.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import Combine

@MainActor
final class AppCoordinator : ObservableObject {
    
    var overlay     : OverlayCoordinator
    var settings    : SettingsCoordinator
    var windows     : WindowCoordinator
    
    let env : AppEnv
    
    init(env: AppEnv) {
        
        self.env = env
        
        /// Create Window Coordinator
        self.windows = WindowCoordinator()
        
        
        self.overlay = OverlayCoordinator(d: self.env)
        
        self.settings = SettingsCoordinator(
            windows: windows,
            deps: self.env
        )
    }
    
    deinit {}
}
