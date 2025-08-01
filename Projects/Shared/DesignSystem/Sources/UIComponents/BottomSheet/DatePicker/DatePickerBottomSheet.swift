//
//  DatePickerBottomSheet.swift
//  Shared
//
//  Created by 이지훈 on 6/18/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI

public struct DatePickerBottomSheet: View {
    @Binding public var selectedDate: Date
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    
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
        HStack(spacing: 0) {
            Picker("Month", selection: $selectedMonth) {
                ForEach(1...12, id: \.self) { month in
                    Text(months[month - 1])
                        .tag(month)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            .clipped()
            
            Picker("Year", selection: $selectedYear) {
                ForEach(years, id: \.self) { year in
                    Text(String(year))
                        .tag(year)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            .clipped()
        }
        .onChange(of: selectedMonth) { _, _ in
            updateSelectedDate()
        }
        .onChange(of: selectedYear) { _, _ in
            updateSelectedDate()
        }
        .onAppear {
            selectedMonth = Calendar.current.component(.month, from: selectedDate)
            selectedYear = Calendar.current.component(.year, from: selectedDate)
        }
    }
    
    private func updateSelectedDate() {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = 1
        
        if let newDate = Calendar.current.date(from: components) {
            selectedDate = newDate
        }
    }
}
