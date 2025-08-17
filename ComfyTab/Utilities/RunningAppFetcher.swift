//
//  RunningAppFetcher.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/14/25.
//

import Foundation
import AppKit

class RunningAppFetcher {
    
    // MARK: - Public API's
    /// Get all running applications
    public static func fetchRunningApps() throws -> [RunningApp] {
        
        var runningApps: [RunningApp] = []
        for app in NSWorkspace.shared.runningApplications {
            
            guard app.activationPolicy == .regular else { continue }
            
            /// Create a Acessibilitty Element
            let axElement = AXUIElementCreateApplication(app.processIdentifier)
            let name = app.localizedName ?? ""
            let hidden = app.isHidden
            let isTerminated = app.isTerminated
            let icon = app.icon
            let pid = app.processIdentifier
            let bundleID = app.bundleIdentifier

            /// if it is minimized we can keep going, later on we can keep a flag
            if isMinimized(axElement, appName: name) { continue }
            

            runningApps.append(
                RunningApp(
                    name: name,
                    hidden: hidden,
                    isTerminated: isTerminated,
                    icon: icon,
                    bundleID: bundleID,
                    pid: pid
                )
            )
        }
        
        return runningApps
    }
    
    // MARK: - Private API's
    private static func isMinimized(
        _ axElement: AXUIElement,
        appName: String
    ) -> Bool {
        /// Copy Windows into value
        var value: AnyObject?
        var result =  AXUIElementCopyAttributeValue(axElement, kAXWindowsAttribute as CFString, &value)
        
        
        if result != .success {
            print("Failed to get windows for app: \(appName) — AXError: \(result.rawValue)")
            
            // Try main window
            result = AXUIElementCopyAttributeValue(axElement, kAXMainWindowAttribute as CFString, &value)
            if result != .success {
                print("Failed To Get Main Window - AXError: \(result.rawValue)")
                
                // Try focused window
                result = AXUIElementCopyAttributeValue(axElement, kAXFocusedWindowAttribute as CFString, &value)
                if result != .success {
                    print("Failed To Get Focused Window - AXError: \(result.rawValue)")
                    return false // No usable window
                }
            }
            
            // If we got a single window, wrap in array
            value = [value] as AnyObject
        }
        
        guard let windows = value as? [AXUIElement], !windows.isEmpty else {
            print("No windows found for \(appName)")
            return false
        }
        
        /// if we have windows
        if let windows = value as? [AXUIElement] {
            if !windows.isEmpty {
                
                let allMin = windows.allSatisfy { window in
                    
                    print("STATS:")
                    printAllElements(window)
                    print("================")

                    /// Check Minimized Property
                    var minimized: AnyObject?
                    if AXUIElementCopyAttributeValue(window, kAXMinimizedAttribute as CFString, &minimized) == .success {
                        if let isMin = minimized as? Bool, isMin {
                            return true
                        }
                    }
                    
                    /// If Minimized Property isnt found we can check its size
                    var sizeValue: AnyObject?
                    if AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &sizeValue) == .success {
                        if let size = sizeValue as? CGSize, size.width == 0 || size.height == 0 {
                            return true
                        }
                    }
                    
                    /// Position Value
                    var posValue: AnyObject?
                    if AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &posValue) == .success {
                        if let pos = posValue as? CGPoint, pos.y > 2000 {
                            return true
                        }
                    }
                    
                    return false
                }
                
                return allMin
            } else {
                print("No windows found for \(appName)")
            }
        } else {
            print("Coudlnt find windows for \(appName)")
        }
        return false
    }
    
    
    // MARK: - Helper Private Methods
    private static func printAllElements(_ axElement: AXUIElement) {
        var attrNamesCF: CFArray?
        let err = AXUIElementCopyAttributeNames(axElement, &attrNamesCF)
        guard err == .success, let attrNames = attrNamesCF as? [String] else {
            print("⚠️ Failed to get attribute names: \(err.rawValue)")
            return
        }
        
        for name in attrNames {
            var value: AnyObject?
            let valErr = AXUIElementCopyAttributeValue(axElement, name as CFString, &value)
            if valErr != .success {
                print("  \(name): (error \(valErr.rawValue))")
                continue
            }
            
            if let arr = value as? [AnyObject] {
                print("  \(name): Array (\(arr.count) items)")
                for (i, item) in arr.enumerated() {
                    print("    [\(i)]: \(item)")
                }
            } else {
                print("  \(name): \(value ?? "nil" as AnyObject)")
            }
        }
    }
}
