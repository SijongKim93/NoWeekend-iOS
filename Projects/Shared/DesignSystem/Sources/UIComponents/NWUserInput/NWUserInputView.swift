//
//  NWStepView.swift
//  DesignSystem
//
//  Created by SiJongKim on 7/4/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI

// MARK: - Step View Component

public struct NWUserInputView<Content: View>: View {
    private let title: String
    private let subtitle: String?
    private let titleAlignment: HorizontalAlignment
    private let spacing: CGFloat
    private let content: Content
    
    public init(
        title: String,
        subtitle: String? = nil,
        titleAlignment: HorizontalAlignment = .center,
        spacing: CGFloat = 8,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.titleAlignment = titleAlignment
        self.spacing = spacing
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: titleAlignment) {
            headerView
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    private var headerView: some View {
        VStack(alignment: titleAlignment, spacing: spacing) {
            Text(title)
                .font(.heading2)
                .foregroundColor(DS.Colors.Neutral.black)
                .multilineTextAlignment(titleAlignment == .center ? .center : .leading)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.body1)
                    .foregroundColor(DS.Colors.Text.disable)
                    .multilineTextAlignment(titleAlignment == .center ? .center : .leading)
            }
        }
    }
}




