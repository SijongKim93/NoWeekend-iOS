//
//  VacationCardView.swift
//  Home
//
//  Created by 김나희 on 6/29/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI
import DesignSystem

struct VacationCardView<Content: View>: View {
    let vactionType: VacationCardType
    /// 가변 텍스트
    /// shorts: subtitle, long: title
    let variableText: String
    let attributedText: AttributedString?
    let onTap: () -> Void
    let content: () -> Content

    init(
        vactionType: VacationCardType,
        variableText: String,
        attributedText: AttributedString? = nil,
        onTap: @escaping () -> Void = {},
        @ViewBuilder content: @escaping () -> Content = { EmptyView() }
    ) {
        self.vactionType = vactionType
        self.variableText = variableText
        self.attributedText = attributedText
        self.onTap = onTap
        self.content = content
    }

    var body: some View {
        Group {
            if vactionType.viewType == .long {
                HStack(alignment: .center, spacing: 16) {
                    iconView
                    textStackLong
                    Spacer()
                    addButton
                }
            } else {
                VStack(alignment: .leading) {
                    HStack {
                        iconView
                        Spacer()
                        VStack {
                            addButton
                            Spacer()
                        }
                    }
                    .padding(.bottom, 16)
                    textStackShort
                }
            }
            content()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .background(DS.Colors.Neutral.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(DS.Colors.Border.border01, lineWidth: 1)
        )
    }

    private var iconView: some View {
        vactionType.icon
            .frame(width: 62, height: 62)
    }

    private var addButton: some View {
        Button(action: onTap) {
            DS.Images.icnPlus
        }
        .frame(width: 24, height: 24)
    }

    private var textStackLong: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(vactionType.text)
                .font(.subtitle1)
                .foregroundColor(DS.Colors.Text.body)
            if let attributedText {
                Text(attributedText)
                    .font(.heading6)
            } else {
                Text(variableText)
                    .font(.heading6)
                    .foregroundColor(DS.Colors.Text.netural)
            }
        }
    }

    private var textStackShort: some View {
        VStack(alignment: .leading) {
            Text(variableText)
                .font(.subtitle1)
                .foregroundColor(DS.Colors.Text.body)
                .padding(.bottom, 4)
            if let attributedText {
                Text(attributedText)
                    .font(.heading6)
            } else {
                Text(vactionType.text)
                    .font(.heading6)
                    .foregroundColor(DS.Colors.Text.netural)
            }
        }
    }
}
