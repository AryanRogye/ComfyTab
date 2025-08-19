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
        SettingsWindowScene(appDelegate: appDelegate)
        ComfyTabMenuBar()
            .environmentObject(appDelegate.appCoordinator.settingsManager)
    }
}

#if DEBUG
let showDebug = false
#endif
