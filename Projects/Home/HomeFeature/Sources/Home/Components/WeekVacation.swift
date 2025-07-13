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
    @ObservedObject var store: HomeStore
    
    var body: some View {
        VStack {
            HStack {
                Text("6월 첫째주 휴가를 추천드려요")
                    .font(.heading5)
                Spacer()
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
