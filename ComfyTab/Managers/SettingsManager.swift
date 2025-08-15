//
//  SettingsManager.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/15/25.
//

import Combine
import Foundation
import AppKit

/// Class Is The Main Apps Manager For Everything
/// All Managers will retreive data through this object,
/// This Object is responsible for saving/persisting data,
/// And Setting Default Values for things
class SettingsManager : ObservableObject {
    
    /// Keys
    private enum Keys {
        static let modifierKey = "modifierKey"
    }
    /// Defaults
    /// I do this because in init we can inject different settings
    /// and its nicer to test with
    private var defaults: UserDefaults
    
    @Published var modifierKey: NSEvent.ModifierFlags {
        didSet {
            defaults.set(modifierKey.rawValue, forKey: Keys.modifierKey)
        }
    }
    
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.modifierKey = .option
        
        loadDefaults()
    }
}

/// Loading Logic
extension SettingsManager {
    
    private func loadDefaults() {
        loadModifierKey()
    }
    
    private func loadModifierKey() {
        let raw = defaults.object(forKey: Keys.modifierKey) as? UInt ?? NSEvent.ModifierFlags.option.rawValue
        self.modifierKey = NSEvent.ModifierFlags(rawValue: raw)
    }
}
