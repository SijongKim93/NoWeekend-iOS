//
//  MypageSettingRow.swift
//  Calendar
//
//  Created by SiJongKim on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI
import DesignSystem

public struct SettingSection<Content: View>: View {
    let title: String
    let content: Content
    
    public init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center) {
                Text(title)
                    .font(.body1)
<<<<<<< HEAD
                    .foregroundColor(DS.Colors.Text.body)
=======
                    .foregroundColor(DS.Colors.Text.body)//body
>>>>>>> a5a7495ff885613ef21bf6147c4dbb969a6d4598
                
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(height: 24)
            
            content
        }
    }
}

public struct SettingRow: View {
    let title: String
    let titleFont: Font
    let rightText: String?
    let rightTextColor: Color
    let rightIcon: Image?
    let hasChevron: Bool
    let hasToggle: Bool
    let isToggleOn: Binding<Bool>?
    let action: (() -> Void)?
    
    public init(
        title: String,
        titleFont: Font = .body1,
        rightText: String? = nil,
        rightTextColor: Color = DS.Colors.Text.body,
        rightIcon: Image? = nil,
        hasChevron: Bool = false,
        hasToggle: Bool = false,
        isToggleOn: Binding<Bool>? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.titleFont = titleFont
        self.rightText = rightText
        self.rightTextColor = rightTextColor
        self.rightIcon = rightIcon
        self.hasChevron = hasChevron
        self.hasToggle = hasToggle
        self.isToggleOn = isToggleOn
        self.action = action
    }
    
    public var body: some View {
        Button(action: { action?() }) {
            HStack {
                Text(title)
                    .font(titleFont)
                    .foregroundColor(DS.Colors.Text.netural)
                
                Spacer()
                
<<<<<<< HEAD
=======
                // 오른쪽 콘텐츠
>>>>>>> a5a7495ff885613ef21bf6147c4dbb969a6d4598
                if hasToggle, let isToggleOn = isToggleOn {
                    Toggle("", isOn: isToggleOn)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: DS.Colors.Toast._500))
                } else {
                    HStack(spacing: 4) {
                        if let rightIcon = rightIcon {
                            rightIcon
                                .resizable()
                                .padding(4)
                                .frame(width: 24, height: 24)
                        }
                        
                        if let rightText = rightText {
                            Text(rightText)
                                .font(.body2)
                                .foregroundColor(rightTextColor)
                        }
                        
                        if hasChevron {
                            DS.Images.icnChevronRight
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .background(DS.Colors.Background.normal)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 구분선

public struct SettingDivider: View {
    public init() {}
    
    public var body: some View {
        Divider()
            .padding(.horizontal, 20)
    }
}

// MARK: - 편의 생성자

public extension SettingRow {
    // 기본 로우
    static func basic(title: String, titleFont: Font = .body1, action: @escaping () -> Void) -> SettingRow {
        SettingRow(title: title, titleFont: titleFont, hasChevron: false, action: action)
    }
    
    // 기본 로우 + 오른쪽 화살표
    static func basicWithArrow(title: String, titleFont: Font = .body1, action: @escaping () -> Void) -> SettingRow {
        SettingRow(title: title, titleFont: titleFont, hasChevron: true, action: action)
    }
    
    // 오른쪽 텍스트 + 화살표
    static func withRightText(title: String, titleFont: Font = .body1, rightText: String, color: Color = DS.Colors.Text.netural, action: @escaping () -> Void) -> SettingRow {
        SettingRow(title: title, rightText: rightText, rightTextColor: color, hasChevron: true, action: action)
    }
    
    // 오른쪽 아이콘 + 텍스트 + 화살표
    static func withIconAndRightText(title: String, titleFont: Font = .body1, rightText: String, rightTextColor: Color = DS.Colors.Text.netural, rightIcon: Image, action: @escaping () -> Void
    ) -> SettingRow {
        SettingRow(title: title, titleFont: titleFont, rightText: rightText, rightTextColor: rightTextColor, rightIcon: rightIcon, hasChevron: true, action: action
        )
    }

    
    // 컬러 텍스트 + 화살표 (개인, 업무 등)
    static func withColorText(title: String, titleFont: Font = .body1, rightText: String, color: Color, action: @escaping () -> Void) -> SettingRow {
        SettingRow(title: title, rightText: rightText, rightTextColor: color, hasChevron: true, action: action)
    }
    
    // 오른쪽 텍스트만 (화살표 없음)
    static func withRightTextOnly(title: String, titleFont: Font, rightText: String, color: Color = DS.Colors.Text.netural, action: (() -> Void)? = nil) -> SettingRow {
        SettingRow(title: title, titleFont: titleFont, rightText: rightText, rightTextColor: color, hasChevron: false, action: action)
    }
    
    // 토글 스위치
    static func withToggle(title: String, titleFont: Font = .body1, isOn: Binding<Bool>) -> SettingRow {
        SettingRow(title: title, hasToggle: true, isToggleOn: isOn)
    }
}
