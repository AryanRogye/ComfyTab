//
//  PermissionsView.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/27/25.
//

import SwiftUI

public struct PermissionsView: View {
    
    @ObservedObject var permissionsManager: PermissionManager = .shared
    
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
                permissionsManager.requestAcessibilityPermission()
            }) {
                Group {
                    if permissionsManager.isAccessibilityEnabled {
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
                        .fill(permissionsManager.isAccessibilityEnabled
                              ? Color.green.opacity(0.2)
                              : Color.red.opacity(0.2)
                        )
                }
            }
            .disabled(permissionsManager.isAccessibilityEnabled)
            .buttonStyle(.plain)
        }
    }
}
