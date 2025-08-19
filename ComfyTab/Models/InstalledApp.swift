//
//  InstalledApp.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/19/25.
//

import AppKit

struct InstalledApp: Hashable {
    let url: URL
    let name: String
    let bundleID: String?
    
    init(
        url: URL,
        name: String,
        bundleID: String?
    ) {
        self.url = url
        self.name = name
        self.bundleID = bundleID
    }
}
