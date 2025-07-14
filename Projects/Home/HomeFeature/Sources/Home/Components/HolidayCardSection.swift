//
//  CardPageControl.swift
//  HomeFeature
//
//  Created by 김나희 on 7/14/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI
import DesignSystem
import HomeDomain

struct HolidayCardSection: View {
    let holidays: [Holiday]
    let onAddTapped: (Holiday) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("올해 남은 공휴일을 모아봤어요")
                    .font(.heading5)
                Spacer()
            }
            .padding(.top, 24)
            .padding(.bottom, 20)
            .padding(.horizontal, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(holidays, id: \.date) { holiday in
                        HolidayCard(holiday: holiday) {
                            onAddTapped(holiday)
                        }
                    }
                }
                .padding(.leading, 20)
                .padding(.bottom, 24)
            }
        }
    }
}

struct HolidayCard: View {
    let holiday: Holiday
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(holiday.dateString)
                    .font(.subtitle1)
                    .foregroundColor(DS.Colors.Text.body)
                Spacer()
                Button(action: onAdd) {
                    DS.Images.icnPlus
                        .foregroundColor(DS.Colors.Neutral.gray700)
                }
                .frame(width: 24, height: 24)
            }
            Text(holiday.name)
                .font(.heading6)
                .foregroundColor(DS.Colors.Text.netural)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .frame(width: 160, height: 96)
        .background(DS.Colors.Background.normal)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .inset(by: 0.5)
                .stroke(DS.Colors.Border.border01, lineWidth: 1)
        )
    }
}
