//
//  RunningApp.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/16/25.
//

import SwiftUI
import Cocoa
import AppKit
import Darwin

struct RunningApp: Identifiable, Equatable, Hashable {
    var name    : String
    var icon    : NSImage?
    var hidden  : Bool
    var isTerminated: Bool
    var bundleID: String?
    var pid     : pid_t
    
    /// stable ID for SwiftUI diffing
    var id: String {
        if let bundleID = bundleID {
            return "\(bundleID)-\(pid)"
        } else {
            return "pid-\(pid)"
        }
    }
    
    init(
        name: String,
        hidden: Bool,
        isTerminated: Bool,
        icon: NSImage? = nil,
        bundleID: String?,
        pid: pid_t
    ) {
        self.name = name
        self.hidden = hidden
        self.isTerminated = isTerminated
        self.icon = icon
        self.bundleID = bundleID
        self.pid = pid
    }
    
    public func focusApp() {
        if let runningApp = NSRunningApplication(processIdentifier: self.pid) {
            runningApp.activate(options: [.activateAllWindows])
            launchApp()
        }
    }
    
    private func launchApp() {
        print("Launching App \(name)")
        guard let bundleID = bundleID, bundleID != "" else { return }
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            print("❌ No app found for bundle ID: \(bundleID)")
            return
        }
        
        let config = NSWorkspace.OpenConfiguration()
        config.activates = true // bring to front after launch
        
        NSWorkspace.shared.openApplication(at: url,
                                           configuration: config) { app, error in
            if let error = error {
                print("❌ Launch failed: \(error.localizedDescription)")
            } else {
                print("✅ Launched \(bundleID)")
            }
        }
    }
    
    func revealInFinder() {
        if let ra = NSRunningApplication(processIdentifier: pid), let bundleURL = ra.bundleURL {
            NSWorkspace.shared.activateFileViewerSelecting([bundleURL])
            return
        }
        
        if let bid = bundleID,
           let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bid) {
            NSWorkspace.shared.activateFileViewerSelecting([appURL])
            return
        }
        
        // 4) Nothing to reveal
        NSSound.beep()
    }
}
