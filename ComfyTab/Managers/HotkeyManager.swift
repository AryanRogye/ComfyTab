//
//  HotkeyManager.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/27/25.
//

import HotKey
import AppKit
import Combine

public class HotkeyManager {
    
    private(set) var hotkey: HotKey?
    private(set) var permissionManager : PermissionManager
    
    init(permissionManager: PermissionManager) {
        self.permissionManager = permissionManager
    }
    
    func setupHotkey() {
        hotkey = HotKey(key: .tab, modifiers: [.control])
        
        hotkey?.keyDownHandler = {
            guard self.permissionManager.isAccessibilityEnabled else { return }
            print("Hot Key Triggered")
        }
        hotkey?.keyUpHandler = {
            guard self.permissionManager.isAccessibilityEnabled else { return }
            print("Hot Key Released")
        }
    }
}
