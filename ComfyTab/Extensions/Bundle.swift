//
//  Bundle.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/17/25.
//

import Foundation

extension Bundle {
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as! String
    }
    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as! String
    }
}
