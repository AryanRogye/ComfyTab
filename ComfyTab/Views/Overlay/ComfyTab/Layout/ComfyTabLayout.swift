//
//  ComfyTabLayout.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/19/25.
//

import SwiftUI

struct ComfyTabSlice: Identifiable, Hashable {
    let id: String        // stable (use bundleID)
    let index: Int
    let app: RunningApp
    let start: Angle
    let end: Angle
}

enum ComfyTabLayout {
    static func makeSlices(_ apps: [RunningApp]) -> [ComfyTabSlice] {
        guard !apps.isEmpty else { return [] }
        let count = apps.count
        return apps.enumerated().map { i, app in
            let start = Angle(degrees: Double(i) * 360.0 / Double(count))
            let end   = Angle(degrees: Double(i + 1) * 360.0 / Double(count))
            return ComfyTabSlice(id: app.bundleID ?? "()-\(app.pid)", index: i, app: app, start: start, end: end)
        }
    }
}
