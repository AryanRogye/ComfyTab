//
//  AppDelegate.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/27/25.
//

import AppKit
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var appCoordinator : AppCoordinator
    var appEnv = AppEnv()
    
    @MainActor
    override init() {
        appCoordinator = AppCoordinator(env: appEnv)
    }
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
    }
    
    public func applicationWillTerminate(_ notification: Notification) {
    }
    
    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
