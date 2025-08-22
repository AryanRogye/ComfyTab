//
//  OverlayDeps.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/21/25.
//

protocol OverlayDeps {
    var runningAppService: any RunningAppService { get }
    var settingsService: any SettingsService { get }
}
