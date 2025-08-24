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
    
    var body: some Scene {
        ComfyTabMenuBar(settingsCoordinator: appDelegate.appCoordinator.settingsCoordinator)
    }
}

#if DEBUG
let showDebug = false
#endif
