//
//  ComfyTabApp.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/27/25.
//

import SwiftUI

@main
struct ComfyTabApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
    }
    
    var body: some Scene {
        ComfyTabMenuBar(
            appEnv: appDelegate.appEnv,
            settingsCoordinator: appDelegate.appCoordinator.settings
        )
    }
}

#if DEBUG
let showDebug = false
#endif
