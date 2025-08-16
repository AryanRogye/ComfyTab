//
//  SettingsManager.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/15/25.
//

import Combine
import Foundation
import AppKit
import ServiceManagement

/// Class Is The Main Apps Manager For Everything
/// All Managers will retreive data through this object,
/// This Object is responsible for saving/persisting data,
/// And Setting Default Values for things
class SettingsManager : ObservableObject {
    
    /// Keys
    private enum Keys {
        static let modifierKey          = "modifierKey"
        static let colorSchemeSetting   = "colorSchemeSetting"
        static let showDockIcon         = "showDockIcon"
        static let launchAtLogin        = "launchAtLogin"
    }
    
    /// Defaults
    /// I do this because in init we can inject different settings
    /// and its nicer to test with
    private var defaults: UserDefaults
    
    /// Modifier Key For the Shortcut
    @Published var modifierKey: ModifierKey {
        didSet {
            defaults.set(modifierKey.rawValue, forKey: Keys.modifierKey)
        }
    }
    
    /// Colorscheme of the App, System by default
    @Published var colorScheme: ColorSchemeSetting {
        didSet {
            defaults.set(colorScheme.rawValue, forKey: Keys.colorSchemeSetting)
        }
    }
    
    /// Switch to show Dock Item while app is running, minus the Settings Page
    /// The Settings page will always show the Dock Item
    @Published var showDockIcon: Bool {
        didSet {
            defaults.set(showDockIcon, forKey: Keys.showDockIcon)
        }
    }
    
    @Published var launchAtLogin: Bool
    @Published var isSettingsWindowOpen: Bool = false
    
    var cancellables: Set<AnyCancellable> = []
    
    
    /// Load in Defaults
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.launchAtLogin = (SMAppService.mainApp.status == .enabled)
        self.modifierKey = .option
        self.colorScheme = .system
        self.showDockIcon = false
        
        loadDefaults()
        
        $launchAtLogin
            .sink { [weak self] launchAtLogin in
                guard let self = self else { return }
                /// If We Set Launch At Login
                if launchAtLogin {
                    if SMAppService.mainApp.status == .enabled { return }
                    do {
                        try SMAppService.mainApp.register()
                    } catch {
                        print("Couldnt Register ComfyTab to Launch At Login \(error.localizedDescription)")
                        /// Toggle it Off
                        self.launchAtLogin = false
                    }
                }
                /// If Launch At Logic is Turned off
                else {
                    /// ONLY go through if the status is enabled
                    if SMAppService.mainApp.status != .enabled { return }
                    do {
                        try SMAppService.mainApp.unregister()
                    } catch {
                        print("Couldnt Turn Off Launch At Logic for ComfyTab \(error.localizedDescription)")
                        self.launchAtLogin = true
                    }
                }
            }
            .store(in: &cancellables)
        
        /// 1. Settings window open → always show (overrides everything).
        /// 2. User enabled Dock icon → always show (even if settings window is closed).
        /// 3. Neither true → hide (after the delay).
        
        $showDockIcon
            .sink { [weak self] showDockIcon in
                guard let self = self else { return }
                if showDockIcon {
                    /// at anytime if showDockIcon is called, we can just show the App Icon
                    self.showAppIcon()
                } else {
                    /// if the settings page is open when we toggle this off, which most likely we will
                    /// exit early because the settingsWindowOpen bind handles that
                    if self.isSettingsWindowOpen { return }
                    /// I dont think we would ever get here but if we do, just hide the app icon
                    self.hideAppIcon()
                }
            }
            .store(in: &cancellables)
        
        $isSettingsWindowOpen
            .sink { [weak self] isOpen in
                guard let self = self else { return }
                if isOpen {
                    /// By default if the settings page is open we always show the App Icon,/
                    self.showAppIcon()
                } else {
                    /// If the user decides that they want to show the dock icon we just return early
                    if self.showDockIcon { return }
                    /// if they have showDockIcon toggled off then we show the hide the dock icon when closing
                    self.hideAppIcon()
                }
            }
            .store(in: &cancellables)
        
        /// Handling Color Scheme
        $colorScheme
            .sink { colorScheme in
                switch colorScheme {
                case .system:
                    NSApp.appearance = nil
                case .light:
                    NSApp.appearance = NSAppearance(named: .aqua)
                case .dark:
                    NSApp.appearance = NSAppearance(named: .darkAqua)
                }
            }
            .store(in: &cancellables)
    }
    
    private var isShowingAppIcon: Bool = false
}

extension SettingsManager {
    
    private func showAppIcon() {
        if !isShowingAppIcon {
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
            isShowingAppIcon  = true
        }
    }
    
    private func hideAppIcon() {
        if isShowingAppIcon {
            /// makes sure we don’t hide the icon if the user flipped something back during that second.
            /// I use a Second cuz its a bit safer
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self,
                      !self.isSettingsWindowOpen,
                      !self.showDockIcon
                else {
                    return
                }
                
                NSApp.setActivationPolicy(.accessory)
                isShowingAppIcon = false
            }
        }
    }
}

/// Loading Logic
extension SettingsManager {
    
    private func loadDefaults() {
        loadModifierKey()
        loadColorScheme()
        loadShowDockIcon()
    }
    
    // MARK: - Load Modifier Key
    private func loadModifierKey() {
        if let raw = defaults.object(forKey: Keys.modifierKey) as? UInt {
            self.modifierKey = ModifierKey(rawValue: raw) ?? .option
        } else {
            self.modifierKey = .option
        }
    }
    
    // MARK: - Load Color Scheme
    private func loadColorScheme() {
        if let raw = defaults.object(forKey: Keys.colorSchemeSetting) as? String {
            self.colorScheme = ColorSchemeSetting(rawValue: raw) ?? .system
        } else {
            self.colorScheme = .system
        }
    }
    
    // MARK: - Load Show Dock Icon
    private func loadShowDockIcon() {
        if let showDockIcon = defaults.object(forKey: Keys.showDockIcon) as? Bool {
            self.showDockIcon = showDockIcon
        } else {
            self.showDockIcon = false
        }
    }
}
