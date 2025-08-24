//
//  OverlayCoordinator.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/20/25.
//

import SwiftUI

@MainActor
class OverlayCoordinator {
    
    /// Dependencies for the overlay
    let dependencies: OverlayDeps
    
    /// Overlay NSPanel
    var overlay : NSPanel? = nil
    
    /// Overlay ViewModel
    var overlayViewModel: OverlayViewModel? = nil
    /// HotKeyManager
    var hotkeyManager: HotkeyCoordinator? = nil
    
    /// Previous focused window before the overlay was shown
    private weak var previousFocousedWindow: NSRunningApplication?
    
    
    init(d : OverlayDeps) {
        self.dependencies = d
        
        prepare()
        hotkeyManager?.setupHotkey()
    }
    
    private func prepare() {
        
        self.overlayViewModel = OverlayViewModel(
            deps: dependencies
        )
        self.hotkeyManager = HotkeyCoordinator(
            deps: dependencies,
            overlayViewModel: overlayViewModel!,
            onShow: self.show,
            onHide: self.hide
        )
    }
}

/// MARK: - Overlay Window Management
extension OverlayCoordinator {
    
    private func prepareOverlayWindow() {
        guard let screen = NSScreen.main else { return }
        guard let overlayViewModel = overlayViewModel else { return }
        
        overlay = FocusablePanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        /// Allow content to draw outside panel bounds
        overlay?.setFrame(screen.frame, display: true)
        overlay?.contentView?.wantsLayer = true
        overlay?.title = "ComfyTab"
        
        let overlayRaw = CGWindowLevelForKey(.overlayWindow)
        overlay?.level = NSWindow.Level(rawValue: Int(overlayRaw))
        
        overlay?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        overlay?.isMovableByWindowBackground = false
        overlay?.backgroundColor = .clear
        overlay?.isOpaque = false
        overlay?.hasShadow = false
        overlay?.ignoresMouseEvents = false
        overlay?.acceptsMouseMovedEvents = true
        
        let contentView = OverlayContent()
            .environmentObject(overlayViewModel)
        
        let hostingView = NSHostingView(rootView: contentView)
        
        hostingView.wantsLayer = true
        hostingView.layer?.masksToBounds = false
        overlay?.contentView = hostingView
    }
    
    // MARK: - Show Hide Overlay
    public func show() {
        guard let overlayViewModel = overlayViewModel else {
            print("Cant Show, OverlayViewModel is nil")
            return
        }
        if self.overlay == nil {
            prepareOverlayWindow()
            overlay?.layoutIfNeeded()
        }
        guard let overlay = self.overlay else {
            print("Cant Show, Overlay is nil")
            return
        }
        
        if !overlay.isVisible {
            previousFocousedWindow = NSWorkspace.shared.frontmostApplication
            calculateNewScreenPosition()
            NSApp.activate(ignoringOtherApps: true)
            overlayViewModel.isShowing = true
            overlay.makeKeyAndOrderFront(nil)
        }
    }
    
    public func hide() {
        guard let overlayViewModel = overlayViewModel else {
            print("Cant Hide, OverlayViewModel is nil")
            return
        }
        guard let overlay = overlay else {
            print("Cant Hide, Overlay is nil")
            return
        }
        
        if overlay.isVisible {
            overlayViewModel.isShowing = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
                guard let self = self else { return }
                self.overlay?.orderOut(nil)
                self.previousFocousedWindow?.activate(options: [.activateAllWindows])
                self.previousFocousedWindow = nil
            }
        }
    }
    
    private func calculateNewScreenPosition() {
        guard let screen = OverlayHelper.getScreenUnderMouse() else { return }
        overlay?.setFrame(screen.frame, display: true, animate: false)
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
