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
    let vacationBakingStatus: VacationBakingStatus
    let onVacationBakingTapped: () -> Void
    
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
                // TODO: 데이터 넣기
                Text("97°C")
                    .font(.body1)
                    .foregroundColor(DS.Colors.Toast._600)
            }
            .padding(.bottom, 4)
            
            Text(vacationBakingStatus.titleText)
                .font(.heading4)
                .foregroundColor(DS.Colors.Text.netural)
            
            DS.Images.imageMain
                .resizable()
                .frame(width: 140, height: 140)
                .padding(.vertical, 16)
            
            Button(action: onVacationBakingTapped) {
                Text(vacationBakingStatus.buttonText)
                    .font(.body1)
                    .foregroundColor(vacationBakingStatus.isButtonEnabled ? .white : DS.Colors.Text.body)
                    .frame(width: 200, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(vacationBakingStatus.isButtonEnabled ? DS.Colors.Toast._600 : DS.Colors.Background.alternative01)
                    )
            }
            .disabled(!vacationBakingStatus.isButtonEnabled)
            .buttonStyle(PlainButtonStyle())
        }
    }
} 
