//
//  DatePickerSection.swift
//  CalendarFeature
//
//  Created by 이지훈 on 7/12/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import DesignSystem
import SwiftUI

struct DatePickerSection: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var isAllDay: Bool
    @Binding var isStartDateExpanded: Bool
    @Binding var isEndDateExpanded: Bool
    @Binding var isStartTimeExpanded: Bool
    @Binding var isEndTimeExpanded: Bool
    let showTimeControls: Bool
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.M.d (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 24) {
            DateTimeRow(
                title: "시작",
                date: startDate,
                isDateExpanded: $isStartDateExpanded,
                isTimeExpanded: $isStartTimeExpanded,
                isAllDay: isAllDay,
                showTimeControls: showTimeControls,
                dateFormatter: dateFormatter,
                timeFormatter: timeFormatter,
                onDateToggle: toggleStartDate,
                onTimeToggle: toggleStartTime,
                dateContent: {
                    DatePicker("", selection: $startDate, displayedComponents: [.date])
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .onChange(of: startDate, perform: handleStartDateChange)
                },
                timeContent: {
                    DatePicker("", selection: $startDate, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .onChange(of: startDate, perform: handleStartTimeChange)
                }
            )
            
            DateTimeRow(
                title: "종료",
                date: endDate,
                isDateExpanded: $isEndDateExpanded,
                isTimeExpanded: $isEndTimeExpanded,
                isAllDay: isAllDay,
                showTimeControls: showTimeControls,
                dateFormatter: dateFormatter,
                timeFormatter: timeFormatter,
                onDateToggle: toggleEndDate,
                onTimeToggle: toggleEndTime,
                dateContent: {
                    DatePicker("", selection: $endDate, displayedComponents: [.date])
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                },
                timeContent: {
                    DatePicker("", selection: $endDate, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                }
            )
        }
    }
    
    private func toggleStartDate() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isStartDateExpanded.toggle()
            isEndDateExpanded = false
            isStartTimeExpanded = false
            isEndTimeExpanded = false
        }
    }
    
    private func toggleStartTime() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isStartTimeExpanded.toggle()
            isStartDateExpanded = false
            isEndDateExpanded = false
            isEndTimeExpanded = false
        }
    }
    
    private func toggleEndDate() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isEndDateExpanded.toggle()
            isStartDateExpanded = false
            isStartTimeExpanded = false
            isEndTimeExpanded = false
        }
    }
    
    private func toggleEndTime() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isEndTimeExpanded.toggle()
            isStartDateExpanded = false
            isEndDateExpanded = false
            isStartTimeExpanded = false
        }
    }
    
    private func handleStartDateChange(_ newValue: Date) {
        if endDate < newValue {
            endDate = Calendar.current.date(byAdding: .hour, value: 1, to: newValue) ?? newValue
        }
    }
    
    private func handleStartTimeChange(_ newValue: Date) {
        if endDate <= newValue {
            endDate = Calendar.current.date(byAdding: .hour, value: 1, to: newValue) ?? newValue
        }
    }
}

struct DateTimeRow<DateContent: View, TimeContent: View>: View {
    let title: String
    let date: Date
    @Binding var isDateExpanded: Bool
    @Binding var isTimeExpanded: Bool
    let isAllDay: Bool
    let showTimeControls: Bool
    let dateFormatter: DateFormatter
    let timeFormatter: DateFormatter
    let onDateToggle: () -> Void
    let onTimeToggle: () -> Void
    @ViewBuilder let dateContent: () -> DateContent
    @ViewBuilder let timeContent: () -> TimeContent
    
    var body: some View {
        VStack(spacing: 16) {
            Button(action: onDateToggle) {
                HStack {
                    Text(title)
                        .font(.body1)
                        .foregroundColor(DS.Colors.Text.netural)
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        DateDisplayView(
                            text: dateFormatter.string(from: date),
                            isExpanded: isDateExpanded
                        )
                        
                        if !isAllDay && showTimeControls {
                            Button(action: onTimeToggle) {
                                DateDisplayView(
                                    text: timeFormatter.string(from: date),
                                    isExpanded: isTimeExpanded
                                )
                            }
                        }
                    }
                }
            }
            
            if isDateExpanded {
                dateContent()
            }
            
            if isTimeExpanded {
                timeContent()
            }
        }
    }
}

struct DateDisplayView: View {
    let text: String
    let isExpanded: Bool
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(text)
                .font(.body1)
                .foregroundColor(DS.Colors.Text.netural)
                .overlay(
                    Rectangle()
                        .fill(isExpanded ? DS.Colors.Neutral.black : DS.Colors.Border.border01)
                        .frame(height: isExpanded ? 2 : 1)
                        .offset(y: 8),
                    alignment: .bottom
                )
        }
    }
}
