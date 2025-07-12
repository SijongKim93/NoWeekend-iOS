//
//  HomeView.swift
//  HomeFeature
//
//  Created by 김나희 on 7/9/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI
import DesignSystem

struct MainTopView: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("오늘 연차쓸래?")
                    .font(.heading4)
                    .foregroundColor(DS.Colors.Text.netural)
                    .padding(.leading, 26)
                    .padding(.bottom, 8)
                Spacer()
            }
            .padding(.top, 16)
            .padding(.bottom, 32)
            
            HStack(spacing: 4) {
                Text("평균 열정온도:")
                    .font(.body1)
                    .foregroundColor(DS.Colors.Text.body)
                Text("97°C")
                    .font(.body1)
                    .foregroundColor(DS.Colors.Toast._600)
            }
            .padding(.bottom, 4)
            Text("온도를 식히는 휴식 어떠세요?")
                .font(.heading4)
                .foregroundColor(DS.Colors.Text.netural)
            
            DS.Images.imageMain
                .resizable()
                .frame(width: 140, height: 140)
                .padding(.vertical, 16)
            
            NWButton.primary("최대 7일 휴가 굽기", action: { })
                .frame(width: 200, height: 60)
        }
    }
} 
