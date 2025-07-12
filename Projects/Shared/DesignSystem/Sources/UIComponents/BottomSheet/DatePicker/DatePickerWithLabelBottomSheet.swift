//
//  DatePickerWithLabelBottomSheet.swift
//  DesignSystem
//
//  Created by 이지훈 on 6/18/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI

public struct DatePickerWithLabelBottomSheet: View {
    @Binding public var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempSelectedMonth: Int = 0
    @State private var tempSelectedYear: Int = 0
    
    private let months = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    
    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }
    
    private var years: [Int] {
        Array((currentYear - 50)...(currentYear + 50))
    }
    
    public init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
    }
    
    public var body: some View {
        BottomSheetContainer(height: 480) {
            VStack(spacing: 24) {
                BottomSheetHeader(
                    title: "확인하고 싶은",
                    subtitle: "휴가 날짜를 선택해주세요"
                )
                
                HStack(spacing: 0) {
                    Picker("Month", selection: $tempSelectedMonth) {
                        ForEach(1...12, id: \.self) { month in
                            Text(months[month - 1])
                                .tag(month)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    
                    Picker("Year", selection: $tempSelectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text(String(year))
                                .tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                    .clipped()
                }
                .onAppear {
                    tempSelectedMonth = Calendar.current.component(.month, from: selectedDate)
                    tempSelectedYear = Calendar.current.component(.year, from: selectedDate)
                }
                
                Spacer()
                
                NWButton.black(
                    "확인",
                    size: .xl
                ) {
                    applySelectedDate()
                    dismiss()
                }
                .padding(.horizontal, 0)
                .padding(.bottom, 8)
            }
        }
    }
    
    private func applySelectedDate() {
        var components = DateComponents()
        components.year = tempSelectedYear
        components.month = tempSelectedMonth
        
        let currentDay = Calendar.current.component(.day, from: selectedDate)
        
        let tempDate = Calendar.current.date(from: DateComponents(year: tempSelectedYear, month: tempSelectedMonth, day: 1)) ?? selectedDate
        let lastDayOfMonth = Calendar.current.range(of: .day, in: .month, for: tempDate)?.upperBound ?? 1
        
        components.day = min(currentDay, lastDayOfMonth - 1)
        
        if let newDate = Calendar.current.date(from: components) {
            selectedDate = newDate
        }
    }
}
