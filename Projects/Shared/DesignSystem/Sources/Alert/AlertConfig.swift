//
//  iOSAlertConfig.swift
//  DesignSystem
//
//  Created by SiJongKim on 7/14/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI

public struct AlertConfig {
    public let title: String
    public let message: String?
    public let buttons: [AlertButton]
    
    public init(
        title: String,
        message: String? = nil,
        buttons: [AlertButton]
    ) {
        self.title = title
        self.message = message
        self.buttons = buttons
    }
}

public struct AlertButton {
    public let title: String
    public let role: ButtonRole?
    public let action: () -> Void
    
    public init(
        title: String,
        role: ButtonRole? = nil,
        action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.role = role
        self.action = action
    }
    
    public enum ButtonRole {
        case destructive
        case cancel
    }
}
