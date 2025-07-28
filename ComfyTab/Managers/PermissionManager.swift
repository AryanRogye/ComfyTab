//
//  PermissionManager.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/27/25.
//

import Combine
import ApplicationServices
import AppKit

/// Manage All Permissions for the App
class PermissionManager: ObservableObject {
    @Published var isAccessibilityEnabled: Bool = false
    @Published var isDoneCheckingPermissionsStart: Bool = false
    
    init() {
        checkAccessibilityPermission()
        
        if !isAccessibilityEnabled {
            requestAcessibilityPermission()
        }
        
        self.isDoneCheckingPermissionsStart = true
    }
    
    /// Check if Accessibility Permission is Granted
    func checkAccessibilityPermission() {
        let isTrusted = AXIsProcessTrusted()
        DispatchQueue.main.async {
            self.isAccessibilityEnabled = isTrusted
        }
    }
    
    /// Request Accessibility Permissions
    func requestAcessibilityPermission() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true]
        let status = AXIsProcessTrustedWithOptions(options)
        
        if !status {
            print("Accessibility permission denied.")
        } else {
            print("Accessibility permission granted.")
        }
        
        // Keep polling every second until enabled (max 10 tries)
        var tries = 0
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.checkAccessibilityPermission()
            tries += 1
            
            if self.isAccessibilityEnabled || tries > 10 {
                timer.invalidate()
            }
        }
    }
}
