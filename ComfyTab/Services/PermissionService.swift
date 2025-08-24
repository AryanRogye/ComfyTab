//
//  PermissionService.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/21/25.
//

protocol PermissionService {
    var isAccessibilityEnabled : Bool { get set }
    func openPermissionSettings()
    func requestAccessibilityPermission()
}
