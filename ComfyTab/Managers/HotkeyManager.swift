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
    private let permissionManager = PermissionManager.shared
    
    init() {
        
    }
    
    func setupHotkey() {
        hotkey = HotKey(key: .tab, modifiers: [.control])

        hotkey?.keyDownHandler = {
            guard self.permissionManager.isAccessibilityEnabled else { return }
            print("Hot Key Triggered")
        }
    }
}
