//
//  PermissionsView.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/27/25.
//

import SwiftUI

// TODO: Move to a view model
public struct PermissionsView: View {
    
    @EnvironmentObject var permissionManager: PermissionManager
    
    public var body: some View {
        VStack {
            /// Acessibility Permissions
            accessibilityPermissionsView
                .padding([.horizontal, .top])
            Divider()
                .padding(.vertical, 8)
            
            Spacer()
        }
    }
    
    private var accessibilityPermissionsView: some View {
        HStack {
            Text("Accessibility Permissions")
                .font(.headline)
            Spacer()
            
            Button(action: {
                permissionManager.requestAcessibilityPermission()
            }) {
                Group {
                    if permissionManager.isAccessibilityEnabled {
                        Text("Enabled")
                            .foregroundColor(.green)
                    } else {
                        Text("Disabled")
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(permissionManager.isAccessibilityEnabled
                              ? Color.green.opacity(0.2)
                              : Color.red.opacity(0.2)
                        )
                }
            }
            .disabled(permissionManager.isAccessibilityEnabled)
            .buttonStyle(.plain)
        }
    }
}
