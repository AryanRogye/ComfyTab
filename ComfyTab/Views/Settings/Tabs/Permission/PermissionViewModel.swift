//
//  PermissionViewModel.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/21/25.
//

import Combine

class PermissionViewModel: ObservableObject {
    
    var permissionService: any PermissionService
    
    init(deps: PermissionDeps) {
        permissionService = deps.permissionService
    }
}
