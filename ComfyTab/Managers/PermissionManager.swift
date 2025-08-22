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
class PermissionManager: PermissionService, ObservableObject {
    
    @Published var isAccessibilityEnabled   : Bool = false
    
    private var pollTimer: Timer?
    private var testTap: CFMachPort?
    
    init() {
        checkAccessibilityPermission()
        
        if !isAccessibilityEnabled {
            requestAcessibilityPermission()
        }
    }
    
    // MARK: - Accessibility
    /// Check if Accessibility Permission is Granted
    func checkAccessibilityPermission() {
        let isTrusted = AXIsProcessTrusted()
        DispatchQueue.main.async {
            self.isAccessibilityEnabled = isTrusted
        }
    }
    
    func openPermissionSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
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
