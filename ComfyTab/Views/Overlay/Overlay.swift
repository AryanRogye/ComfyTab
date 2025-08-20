//
//  Overlay.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import Combine
import AppKit
import SwiftUI
import os

class FocusablePanel: NSPanel {
    override var canBecomeKey: Bool {
        return true
    }
    override var canBecomeMain: Bool {
        return true
    }
}

class Overlay: ObservableObject {
    
    var overlay: NSPanel!
    let overlayWidth     : CGFloat = 800
    let overlayHeight    : CGFloat = 400
    
    var runningAppManager: RunningAppManager
    var overlayViewModel: OverlayViewModel!
    private weak var previousFocousedWindow: NSRunningApplication?
    
    init(runningAppManager: RunningAppManager, settingsManager: SettingsManager) {
        self.runningAppManager = runningAppManager
        self.overlayViewModel = OverlayViewModel(
            runningAppManager: runningAppManager,
            settingsManager: settingsManager,
            overlay: self
        )
        
        prepareOverlay()
    }
    
    // MARK: - Show Hide Overlay
    public func show() {
        guard let overlay = overlay, !overlay.isVisible else { return }
        
        previousFocousedWindow = NSWorkspace.shared.frontmostApplication
        calculateNewScreenPosition()
        
        overlay.alphaValue = 0
        overlay.orderFrontRegardless()
        NSAnimationContext.runAnimationGroup { _ in
            overlay.animator().alphaValue = 1
            NSApp.activate(ignoringOtherApps: true)
        }
        
        overlayViewModel.isShowing = true
    }
    
    public func hide() {
        guard let overlay = overlay, overlay.isVisible else { return }
        
        NSAnimationContext.runAnimationGroup({ _ in
            overlay.animator().alphaValue = 0
        }, completionHandler: {
            overlay.orderOut(nil)
            self.previousFocousedWindow?.activate(options: [.activateAllWindows])
            self.previousFocousedWindow = nil
            self.overlayViewModel.isShowing = false
        })
    }
    
    // MARK: - Calculate New Show
    
    /// Function will use a new NSScreen.main becuase the user may have a different screen in use
    private func calculateNewScreenPosition() {
        guard let screen = OverlayHelper.getScreenUnderMouse() else { return }
        overlay.setFrame(screen.frame, display: true, animate: false)
    }
    
    // MARK: - Prepare Overlay
    private func prepareOverlay() {
        /// Use A basic screen at the start
        guard let screen = NSScreen.main else { return }
        overlay = FocusablePanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        /// Allow content to draw outside panel bounds
        overlay.setFrame(screen.frame, display: true)
        overlay.contentView?.wantsLayer = true
        overlay.title = "ComfyTab"
        
        let overlayRaw = CGWindowLevelForKey(.overlayWindow)
        overlay.level = NSWindow.Level(rawValue: Int(overlayRaw))
        
        overlay.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        overlay.isMovableByWindowBackground = false
        overlay.backgroundColor = .clear
        overlay.isOpaque = false
        overlay.hasShadow = false
        
        overlay.ignoresMouseEvents = false
        overlay.acceptsMouseMovedEvents = true
        
        
        let contentView = OverlayContent()
            .environmentObject(overlayViewModel)
        
        let hostingView = NSHostingView(rootView: contentView)
        
        /// Allow hosting view to overflow
        hostingView.wantsLayer = true
        hostingView.layer?.masksToBounds = false
        
        overlay.contentView = hostingView
        
        self.hide()
    }
}

/// Quick Mouse Functions
extension Overlay {
    private func centerRect(on screen: NSScreen) -> NSRect {
        let frame = screen.frame
        return NSRect(
            x: frame.origin.x + (frame.width - overlayWidth) / 2,
            y: frame.origin.y + (frame.height - overlayHeight) / 2,
            width: overlayWidth,
            height: overlayHeight
        )
    }
}

struct OverlayHelper {
    /*
     * Function to get the screen that the mouse is under,
     * that way we can return a NSScreen with whatever the mouse is under
     */
    public static func getScreenUnderMouse() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        return NSScreen.screens.first(where: { $0.frame.contains(mouseLocation) })
    }
    
    public static func centerMouse() {
        if let screen = getScreenUnderMouse() {
            let frame = screen.frame
            let center = CGPoint(x: frame.midX, y: frame.midY)
            CGWarpMouseCursorPosition(center)
        }
    }
}
