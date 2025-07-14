//
//  NWTagButton.swift (터치 응답성만 개선)
//  DesignSystem
//
//  Created by SiJongKim on 7/4/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI

// MARK: - Tag Button Component

public struct NWTagButton: View {
    public enum Style {
        case outlined
        case filled
    }
    
    public enum Size {
        case small
        case medium
        case large
        
        var padding: (horizontal: CGFloat, vertical: CGFloat) {
            switch self {
            case .small: return (8, 4)
            case .medium: return (12, 8)
            case .large: return (16, 12)
            }
        }
        
        var font: Font {
            switch self {
            case .small: return .subtitle2
            case .medium: return .subtitle1
            case .large: return .body1
            }
        }
    }
    
    private let title: String
    private let isSelected: Bool
    private let isDisabled: Bool
    private let style: Style
    private let size: Size
    private let fillsAvailableWidth: Bool
    private let action: () -> Void
    
    public init(
        title: String,
        isSelected: Bool = false,
        isDisabled: Bool = false,
        style: Style = .outlined,
        size: Size = .medium,
        fillsAvailableWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.isDisabled = isDisabled
        self.style = style
        self.size = size
        self.fillsAvailableWidth = fillsAvailableWidth
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(size.font)
                .foregroundColor(textColor)
                .padding(.horizontal, size.padding.horizontal)
                .padding(.vertical, size.padding.vertical)
                .frame(maxWidth: fillsAvailableWidth ? .infinity : nil)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: 1)
                )
                .contentShape(Rectangle())
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
        .buttonStyle(PlainButtonStyle())
        .allowsHitTesting(true)
        .highPriorityGesture(
            TapGesture()
                .onEnded { _ in
                    action()
                }
        )
    }
    
    private var textColor: Color {
        if isDisabled {
            return DS.Colors.Text.disable
        }
        
        switch style {
        case .outlined:
            return isSelected ? DS.Colors.Neutral.black : DS.Colors.Text.disable
        case .filled:
            return isSelected ? DS.Colors.Neutral.white : DS.Colors.Text.disable
        }
    }
    
    private var backgroundColor: Color {
        if isDisabled {
            return DS.Colors.Background.alternative01
        }
        
        switch style {
        case .outlined:
            return DS.Colors.Neutral.white
        case .filled:
            return isSelected ? DS.Colors.Toast._500 : DS.Colors.Neutral.white
        }
    }
    
    private var borderColor: Color {
        if isDisabled {
            return DS.Colors.Border.border02
        }
        
        return isSelected ? DS.Colors.Toast._500 : DS.Colors.Border.border02
    }
}
