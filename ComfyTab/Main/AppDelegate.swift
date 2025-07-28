//
//  AppDelegate.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/27/25.
//

import AppKit
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    
    let appCoordinator = AppCoordinator()
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        appCoordinator.prepare()
    }
    
    public func applicationWillTerminate(_ notification: Notification) {
    }
    
    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
