//
//  HomeView.swift
//  HomeFeature
//
//  Created by 김나희 on 7/9/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI
import DesignSystem

struct WeekVacation: View {
    let currentMonth: String
    let currentWeekOfMonth: String
    let onLocationIconTapped: () -> Void
    @ObservedObject var store: HomeStore
    
    var body: some View {
        VStack {
            HStack {
                Text("\(currentMonth)월 \(currentWeekOfMonth)주 휴가를 추천드려요")
                    .font(.heading5)
                Spacer()
                Button(action: onLocationIconTapped) {
                    DS.Images.icnLocation
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 24)
            
            WeekCalendarView(cellContent: { date in
                store.calendarCellContent(for: date) 
                    .frame(width: 38)
            })
        }
        .task {
            await store.loadWeeklySchedules()
        }
    }
} 

#Preview {
    WeekVacation(
        currentMonth: "7", 
        currentWeekOfMonth: "첫째",
        onLocationIconTapped: {}
    )
}
