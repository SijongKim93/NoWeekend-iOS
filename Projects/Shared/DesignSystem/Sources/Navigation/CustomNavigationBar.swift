//
//  CustomNavigationBar.swift
//  Shared
//
//  Created by 이지훈 on 6/18/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI

public struct CustomNavigationBar: View {
    public enum NavigationType {
        case backOnly
        case backWithLabel(String)
        case backWithLabelAndSave(String)
        case cancelWithLabelAndSave(String)
        case labelOnly(String)
    }
    
    public let type: NavigationType
    public let showBackButton: Bool
    public let onBackTapped: (() -> Void)?
    public let onCancelTapped: (() -> Void)?
    public let onSaveTapped: (() -> Void)?
    
    public init(
        type: NavigationType,
        showBackButton: Bool = true,
        onBackTapped: (() -> Void)? = nil,
        onCancelTapped: (() -> Void)? = nil,
        onSaveTapped: (() -> Void)? = nil
    ) {
        self.type = type
        self.showBackButton = showBackButton
        self.onBackTapped = onBackTapped
        self.onCancelTapped = onCancelTapped
        self.onSaveTapped = onSaveTapped
    }
    
    public var body: some View {
        ZStack {
            navigationContent
            centerLabel
        }
        .customNavigationBarStyle()
    }
}

private extension CustomNavigationBar {
    var navigationContent: some View {
        HStack {
            leftButtonContent
            Spacer()
            rightButtonContent
        }
    }
    
    @ViewBuilder
    var leftButtonContent: some View {
        switch type {
        case .backOnly, .backWithLabel, .backWithLabelAndSave:
            if showBackButton {
                Button(action: { onBackTapped?() }) {
                    Image(.icnChevronLeft)
                }
            } else {
                Color.clear
                    .frame(width: 24, height: 24)
            }
            
        case .cancelWithLabelAndSave:
            if showBackButton {
                Button(action: { onCancelTapped?() }) {
                    Text("취소")
                        .font(.heading6)
                        .foregroundColor(DS.Colors.Text.netural)
                }
            } else {
                Color.clear
                    .frame(width: 60, height: 32)
            }
            
        case .labelOnly:
            Color.clear
                .frame(width: 24, height: 24)
        }
    }
    
    @ViewBuilder
    var centerLabel: some View {
        switch type {
        case .backOnly:
            EmptyView()
        case .backWithLabel(let title),
             .backWithLabelAndSave(let title),
             .cancelWithLabelAndSave(let title),
             .labelOnly(let title):
            Text(title)
                .font(.heading6)
                .navigationTitleStyle()
        }
    }
    
    @ViewBuilder
    var rightButtonContent: some View {
        switch type {
        case .backOnly, .backWithLabel, .labelOnly:
            Color.clear
                .frame(width: 60, height: 32)
        case .backWithLabelAndSave, .cancelWithLabelAndSave:
            Button(action: { onSaveTapped?() }) {
                Text("저장")
                    .font(.heading6)
                    .foregroundColor(DS.Colors.Toast._500)
            }
        }
    }
}

private extension View {
    func customNavigationBarStyle() -> some View {
        self
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(Color(.systemBackground))
    }
    
    func navigationTitleStyle() -> some View {
        self
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.primary)
    }
    
    func previewContainerStyle() -> some View {
        self.background(Color.gray.opacity(0.1))
    }
    
    func previewNavigationBarBackground() -> some View {
        self.background(Color.white)
    }
}

public extension CustomNavigationBar {
    static func labelOnly(
        title: String
    ) -> CustomNavigationBar {
        CustomNavigationBar(
            type: .labelOnly(title)
        )
    }
    
    static func conditionalBack(
        title: String,
        showBackButton: Bool,
        onBackTapped: (() -> Void)? = nil
    ) -> CustomNavigationBar {
        CustomNavigationBar(
            type: .backWithLabel(title),
            showBackButton: showBackButton,
            onBackTapped: onBackTapped
        )
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 1) {
        // Back Only
        CustomNavigationBar(
            type: .backOnly,
            onBackTapped: { print("뒤로가기 tapped") }
        )
        .previewNavigationBarBackground()
        
        // Back with Label
        CustomNavigationBar(
            type: .backWithLabel("세부사항"),
            onBackTapped: { print("뒤로가기 tapped") }
        )
        .previewNavigationBarBackground()
        
        // Back with Label and Save
        CustomNavigationBar(
            type: .backWithLabelAndSave("프로필 편집"),
            onBackTapped: { print("뒤로가기 tapped") },
            onSaveTapped: { print("저장하기 tapped") }
        )
        .previewNavigationBarBackground()
        
        // Cancel with Label and Save
        CustomNavigationBar(
            type: .cancelWithLabelAndSave("새 게시물"),
            onCancelTapped: { print("취소 tapped") },
            onSaveTapped: { print("저장하기 tapped") }
        )
        .previewNavigationBarBackground()
    }
    .previewContainerStyle()
}
