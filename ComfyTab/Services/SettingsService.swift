//
//  SettingsService.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/21/25.
//

import Foundation
import Combine

protocol SettingsService {
    /// Modifier Key For the Shortcut
    var modifierKey: ModifierKey { get set }
    var modifierKeyPublisher: AnyPublisher<ModifierKey, Never> { get }
    
    /// Colorscheme of the App, System by default
    var colorScheme: ColorSchemeSetting { get set }
    /// Switch to show Dock Item while app is running, minus the Settings Page
    /// The Settings page will always show the Dock Item
    var showDockIcon: Bool { get set }
    /// We Dont Save this cuz we read this value from the system
    var launchAtLogin: Bool { get set }
    
    /// Switch to enable/disable animation on opening
    var isIntroAnimationEnabled: Bool { get set }
    var isIntroAnimationEnabledPublisher: AnyPublisher<Bool, Never> { get }
    
    /// Switch to show app name under the icon in the donut
    var showAppNameUnderIcon: Bool { get set }
    var showAppNameUnderIconPublisher: AnyPublisher<Bool, Never> { get }
    
    /// Switch to turn hover off and on, on the donut
    var isHoverEffectEnabled: Bool { get set }
    var isHoverEffectEnabledPublisher: AnyPublisher<Bool, Never> { get }
    
    /// Array of Directories that can hold the user Apps
    var directoriesOfApps: [URL] { get set }
    var directoriesOfAppsPublisher: AnyPublisher<[URL], Never> { get }
    
    /// The Currently Open State of the Settings Window
    var isSettingsWindowOpen: Bool { get set }
}
