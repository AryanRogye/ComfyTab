//
//  BehaviorDeps.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/21/25.
//

protocol BehaviorDeps {
    var settingsService: any SettingsService { get }
    var installedAppService: any InstalledAppService { get }
}
