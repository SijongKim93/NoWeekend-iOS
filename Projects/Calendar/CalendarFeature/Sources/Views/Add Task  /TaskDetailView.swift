//
//  TaskDetailView.swift
//  CalendarFeature
//
//  Created by 이지훈 on 7/9/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import DesignSystem
import SwiftUI

public struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    let selectedCategory: TaskCreateCategory
    private let isEditMode: Bool
    
    @Binding private var startDate: Date
    @Binding private var endDate: Date
    @Binding private var isAllDay: Bool
    @Binding private var temperature: Int
    
    @State private var temperatureText: String = "50"
    @State private var selectedVacationType: VacationType = .halfDay
    @State private var isStartDateExpanded = false
    @State private var isEndDateExpanded = false
    @State private var isStartTimeExpanded = false
    @State private var isEndTimeExpanded = false
    
    public init(
        selectedCategory: TaskCreateCategory,
        startDate: Binding<Date>,
        endDate: Binding<Date>,
        isAllDay: Binding<Bool>,
        temperature: Binding<Int>,
        isEditMode: Bool = false
    ) {
        self.selectedCategory = selectedCategory
        self._startDate = startDate
        self._endDate = endDate
        self._isAllDay = isAllDay
        self._temperature = temperature
        self.isEditMode = isEditMode
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            TaskDetailNavigationBar(onBackTapped: { dismiss() }, onSaveTapped: saveDetails)
            
            ScrollView {
                VStack(spacing: 30) {
                    if selectedCategory == .vacation {
                        VacationDetailSection(
                            selectedVacationType: $selectedVacationType,
                            startDate: $startDate,
                            endDate: $endDate,
                            isAllDay: $isAllDay,
                            isStartDateExpanded: $isStartDateExpanded,
                            isEndDateExpanded: $isEndDateExpanded,
                            updateVacationDates: updateVacationDates
                        )
                    } else {
                        GeneralDetailSection(
                            startDate: $startDate,
                            endDate: $endDate,
                            isAllDay: $isAllDay,
                            isStartDateExpanded: $isStartDateExpanded,
                            isEndDateExpanded: $isEndDateExpanded,
                            isStartTimeExpanded: $isStartTimeExpanded,
                            isEndTimeExpanded: $isEndTimeExpanded
                        )
                    }
                    
                    TemperatureInputSection(
                        temperature: $temperature,
                        temperatureText: $temperatureText
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }
            
            Spacer()
        }
        .background(DS.Colors.Background.normal)
        .navigationBarHidden(true)
        .onAppear(perform: setupInitialValues)
    }
    
    private func setupInitialValues() {
        temperatureText = String(temperature)
        
        if selectedCategory == .vacation {
            isAllDay = true
            let calendar = Calendar.current
            startDate = calendar.startOfDay(for: startDate)
            endDate = calendar.startOfDay(for: endDate)
        }
    }
    
    private func updateVacationDates(type: VacationType) {
        let calendar = Calendar.current
        
        switch type {
        case .fullDay:
            isAllDay = true
            startDate = calendar.startOfDay(for: startDate)
            endDate = calendar.startOfDay(for: endDate)
            
        case .halfDay, .morningHalf:
            isAllDay = false
            startDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: startDate) ?? startDate
            endDate = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: startDate) ?? endDate
            
        case .afternoonHalf:
            isAllDay = false
            startDate = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: startDate) ?? startDate
            endDate = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: startDate) ?? endDate
        }
    }
    
    private func saveDetails() {
        let action = isEditMode ? "수정" : "저장"
        if selectedCategory == .vacation {
            print("연차 세부사항 \(action) - 연차 유형: \(selectedVacationType.displayName)")
        } else {
            print("일반 세부사항 \(action) - 하루 종일: \(isAllDay)")
        }
        dismiss()
    }
}

// MARK: - Supporting Views

struct TaskDetailNavigationBar: View {
    let onBackTapped: () -> Void
    let onSaveTapped: () -> Void
    
    var body: some View {
        CustomNavigationBar(
            type: .backWithLabelAndSave("세부사항"),
            onBackTapped: onBackTapped,
            onSaveTapped: onSaveTapped
        )
    }
}

struct VacationDetailSection: View {
    @Binding var selectedVacationType: VacationType
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var isAllDay: Bool
    @Binding var isStartDateExpanded: Bool
    @Binding var isEndDateExpanded: Bool
    let updateVacationDates: (VacationType) -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            VacationTypeSelector(
                selectedVacationType: $selectedVacationType,
                updateVacationDates: updateVacationDates
            )
            
            DatePickerSection(
                startDate: $startDate,
                endDate: $endDate,
                isAllDay: $isAllDay,
                isStartDateExpanded: $isStartDateExpanded,
                isEndDateExpanded: $isEndDateExpanded,
                isStartTimeExpanded: .constant(false),
                isEndTimeExpanded: .constant(false),
                showTimeControls: false
            )
        }
    }
}

struct GeneralDetailSection: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var isAllDay: Bool
    @Binding var isStartDateExpanded: Bool
    @Binding var isEndDateExpanded: Bool
    @Binding var isStartTimeExpanded: Bool
    @Binding var isEndTimeExpanded: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            AllDayToggle(isAllDay: $isAllDay, startDate: $startDate, endDate: $endDate)
            
            DatePickerSection(
                startDate: $startDate,
                endDate: $endDate,
                isAllDay: $isAllDay,
                isStartDateExpanded: $isStartDateExpanded,
                isEndDateExpanded: $isEndDateExpanded,
                isStartTimeExpanded: $isStartTimeExpanded,
                isEndTimeExpanded: $isEndTimeExpanded,
                showTimeControls: true
            )
        }
    }
}

struct VacationTypeSelector: View {
    @Binding var selectedVacationType: VacationType
    let updateVacationDates: (VacationType) -> Void
    
    var body: some View {
        HStack {
            Text("연차 유형")
                .font(.body1)
                .foregroundColor(DS.Colors.Text.netural)
            
            Spacer()
            
            Menu {
                ForEach(VacationType.allCases, id: \.self) { type in
                    Button(action: {
                        selectedVacationType = type
                        updateVacationDates(type)
                    }) {
                        HStack {
                            Text(type.displayName)
                            if selectedVacationType == type {
                                Spacer()
                                DS.Images.icnChecked
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 0) {
                    Text(selectedVacationType.displayName)
                        .font(.body1)
                        .foregroundColor(DS.Colors.Text.netural)
                    
                    DS.Images.icnChevronDown
                        .foregroundColor(DS.Colors.Neutral.gray500)
                }
            }
        }
    }
}

struct AllDayToggle: View {
    @Binding var isAllDay: Bool
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    var body: some View {
        HStack {
            Text("하루 종일")
                .font(.body1)
                .foregroundColor(DS.Colors.Text.netural)
                            
            Spacer()
            
            Toggle("", isOn: $isAllDay)
                .labelsHidden()
                .onChange(of: isAllDay) { _, newValue in
                    if newValue {
                        let calendar = Calendar.current
                        startDate = calendar.startOfDay(for: startDate)
                        endDate = calendar.startOfDay(for: endDate)
                    }
                }
        }
    }
}

struct TemperatureInputSection: View {
    @Binding var temperature: Int
    @Binding var temperatureText: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("열정 온도")
                        .font(.body1)
                        .foregroundColor(DS.Colors.Text.netural)
                    
                    Text("0 ~ 100°C 범위")
                        .font(.body2)
                        .foregroundColor(DS.Colors.Text.disable)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    VStack(spacing: 8) {
                        TextField("50", text: $temperatureText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.leading)
                            .frame(width: 70)
                            .font(.body1)
                            .foregroundColor(DS.Colors.Text.netural)
                            .onChange(of: temperatureText) { _, newValue in
                                updateTemperature(newValue)
                            }
                        
                        Rectangle()
                            .fill(DS.Colors.Border.border01)
                            .frame(width: 70, height: 1)
                    }
                    
                    Text("°C")
                        .font(.body1)
                        .foregroundColor(DS.Colors.Text.netural)
                }
            }
        }
    }
    
    private func updateTemperature(_ newValue: String) {
        let filtered = newValue.filter { $0.isNumber }
        if let number = Int(filtered), number <= 100 {
            temperatureText = filtered
            temperature = number
        } else if filtered.isEmpty {
            temperatureText = ""
            temperature = 0
        } else {
            temperatureText = "100"
            temperature = 100
        }
    }
}

#Preview {
    TaskDetailView(
        selectedCategory: .company,
        startDate: .constant(Date()),
        endDate: .constant(Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()),
        isAllDay: .constant(false),
        temperature: .constant(50)
    )
}
