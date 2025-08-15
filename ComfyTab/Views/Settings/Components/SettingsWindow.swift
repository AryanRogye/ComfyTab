//
//  SettingsWindow.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/15/25.
//

import AppKit
import SwiftUI

/// Settings Window
class AppWindow: NSWindow, NSWindowDelegate {

    var permissionManager: PermissionManager?
    var installedAppManager: InstalledAppManager?
    
    
    deinit {
        print("AppWindow deallocated safely")
    }
    
    func windowWillClose(_ notification: Notification) {
        (NSApp.delegate as? AppDelegate)?.settingsWindow = nil
    }
    
    init(
        permissionManager: PermissionManager,
        installedAppManager: InstalledAppManager
    ) {
        self.permissionManager = permissionManager
        self.installedAppManager = installedAppManager
        
        let contentRect = NSRect(x: 0, y: 0, width: 800, height: 600)
        
        super.init(
            contentRect: contentRect,
            styleMask: [.closable, .miniaturizable, .resizable,
                        .titled, .unifiedTitleAndToolbar, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        self.delegate = self
        
        // Create a container for both the effect and the SwiftUI content
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false
        self.contentView = container
        
        // Background visual effect
        let effectView = NSVisualEffectView()
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.material = .sidebar
        effectView.blendingMode = .behindWindow
        effectView.state = .active
        
        // SwiftUI content
        let view = SettingsView(
            permissionManager: permissionManager, installedAppManager: installedAppManager
        )
//            .environmentObject(permissionManager)
//            .environmentObject(installedAppManager)
        
        let hosting = NSHostingView(rootView: view.ignoresSafeArea())
        hosting.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews in correct order (effectView behind hosting)
        container.addSubview(effectView)
        container.addSubview(hosting)
        
        // Fill constraints for both
        NSLayoutConstraint.activate([
            effectView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            effectView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            effectView.topAnchor.constraint(equalTo: container.topAnchor),
            effectView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            hosting.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            hosting.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            hosting.topAnchor.constraint(equalTo: container.topAnchor),
            hosting.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        // Toolbar setup
        let toolbar = NSToolbar(identifier: "")
        toolbar.displayMode = .iconOnly
        self.toolbar = toolbar
        self.toolbar!.isVisible = true
        self.toolbarStyle = .automatic
        
        self.title = ""
        self.titleVisibility = .visible
        self.titlebarAppearsTransparent = true
    }
}
