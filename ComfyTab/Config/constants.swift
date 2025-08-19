//
//  constants.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/18/25.
//

import SwiftUI

enum AppAnims {
    static let loadingAnimation = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let circleAnimation = Animation.spring(response: 0.2, dampingFraction: 0.8)
}

enum AppDefaultURLS {
    static let urls =
    [
        URL(fileURLWithPath: "/Applications"),
        URL(fileURLWithPath: "/Applications/Utilities"),
        URL(fileURLWithPath: "/System/Applications"),
        URL(fileURLWithPath: "/System/Applications/Utilities"),
        URL(fileURLWithPath: "/System/Library/CoreServices"),
        URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Applications")
    ]
}
