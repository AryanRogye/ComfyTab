//
//  AppDelegate.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/27/25.
//

import AppKit
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    
    let permissionManager = PermissionManager.shared
    let hotkeyManager = HotkeyManager()
    var cancellables = Set<AnyCancellable>()
    
    private var didStart = false
    
    private func realStart() {
        guard !didStart else { return }
        didStart = true
        
        print("Started App With Correct Permissions")
        
        hotkeyManager.setupHotkey()
    }
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        permissionManager.$isAccessibilityEnabled
            .filter { $0 }
            .sink { [weak self] granted in
                guard let self = self else { return }
                if granted {
                    self.realStart()
                }
            }
            .store(in: &cancellables)
    }
    public func applicationWillTerminate(_ notification: Notification) {
    }
    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
