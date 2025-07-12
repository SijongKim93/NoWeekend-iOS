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
            navigationBar
            
            ScrollView {
                VStack(spacing: 30) {
                    if selectedCategory == .vacation {
                        vacationSection
                    } else {
                        dateSection
                    }
                    
                    temperatureSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }
            
            Spacer()
        }
        .background(DS.Colors.Background.normal)
        .navigationBarHidden(true)
        .onAppear {
            setupInitialValues()
        }
    }
    
    private var navigationBar: some View {
        CustomNavigationBar(
            type: .backWithLabelAndSave("세부사항"),
            onBackTapped: {
                dismiss()
            },
            onSaveTapped: {
                saveDetails()
            }
        )
    }
    
    private var vacationSection: some View {
        VStack(spacing: 24) {
            HStack {
                Text("연차 유형")
                    .font(.body1)
                    .foregroundColor(DS.Colors.Text.netural)
                
                Spacer()
                
                Menu {
                    ForEach(VacationType.allCases, id: \.self) { type in
                        Button(action: {
                            selectedVacationType = type
                            updateVacationDates(type: type)
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
            datePickerSection
        }
    }
    
    private var dateSection: some View {
        VStack(spacing: 24) {
            HStack {
                Text("하루 종일")
                    .font(.body1)
                    .foregroundColor(DS.Colors.Text.netural)
                                
                Spacer()
                
                Toggle("", isOn: $isAllDay)
                    .labelsHidden()
                    .onChange(of: isAllDay) { _, newValue in
                        if newValue {
                            // 하루 종일로 설정시 시간을 00:00:00으로 설정
                            let calendar = Calendar.current
                            startDate = calendar.startOfDay(for: startDate)
                            endDate = calendar.startOfDay(for: endDate)
                        }
                    }
            }
            
            datePickerSection
        }
    }
    
    private var datePickerSection: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isStartDateExpanded.toggle()
                        isEndDateExpanded = false
                        isStartTimeExpanded = false
                        isEndTimeExpanded = false
                    }
                }) {
                    HStack {
                        Text("시작")
                            .font(.body1)
                            .foregroundColor(DS.Colors.Text.netural)
                        
                        Spacer()
                        
                        HStack(spacing: 20) {
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(dateFormatter.string(from: startDate))
                                    .font(.body1)
                                    .foregroundColor(DS.Colors.Text.netural)
                                    .overlay(
                                        Rectangle()
                                            .fill(isStartDateExpanded ? DS.Colors.Neutral.black : DS.Colors.Border.border01)
                                            .frame(height: isStartDateExpanded ? 2 : 1)
                                            .offset(y: 8),
                                        alignment: .bottom
                                    )
                            }
                            
                            if !isAllDay && selectedCategory != .vacation {
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        isStartTimeExpanded.toggle()
                                        isStartDateExpanded = false
                                        isEndDateExpanded = false
                                        isEndTimeExpanded = false
                                    }
                                }) {
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text(timeFormatter.string(from: startDate))
                                            .font(.body1)
                                            .foregroundColor(DS.Colors.Text.netural)
                                            .overlay(
                                                Rectangle()
                                                    .fill(isStartTimeExpanded ? DS.Colors.Neutral.black : DS.Colors.Border.border01)
                                                    .frame(height: isStartTimeExpanded ? 2 : 1)
                                                    .offset(y: 8),
                                                alignment: .bottom
                                            )
                                    }
                                }
                            }
                        }
                    }
                }
                
                if isStartDateExpanded {
                    DatePicker("", selection: $startDate, displayedComponents: [.date])
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .onChange(of: startDate) { _, newValue in
                            // 종료일이 시작일보다 이전이면 조정
                            if endDate < newValue {
                                endDate = Calendar.current.date(byAdding: .hour, value: 1, to: newValue) ?? newValue
                            }
                        }
                }
                
                if isStartTimeExpanded {
                    DatePicker("", selection: $startDate, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .onChange(of: startDate) { _, newValue in
                            // 종료시간이 시작시간보다 이전이면 조정
                            if endDate <= newValue {
                                endDate = Calendar.current.date(byAdding: .hour, value: 1, to: newValue) ?? newValue
                            }
                        }
                }
            }
            
            VStack(spacing: 16) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isEndDateExpanded.toggle()
                        isStartDateExpanded = false
                        isStartTimeExpanded = false
                        isEndTimeExpanded = false
                    }
                }) {
                    HStack {
                        Text("종료")
                            .font(.body1)
                            .foregroundColor(DS.Colors.Text.netural)
                        
                        Spacer()
                        
                        HStack(spacing: 20) {
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(dateFormatter.string(from: endDate))
                                    .font(.body1)
                                    .foregroundColor(DS.Colors.Text.netural)
                                    .overlay(
                                        Rectangle()
                                            .fill(isEndDateExpanded ? DS.Colors.Neutral.black : DS.Colors.Border.border01)
                                            .frame(height: isEndDateExpanded ? 2 : 1)
                                            .offset(y: 8),
                                        alignment: .bottom
                                    )
                            }
                            
                            if !isAllDay && selectedCategory != .vacation {
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        isEndTimeExpanded.toggle()
                                        isStartDateExpanded = false
                                        isEndDateExpanded = false
                                        isStartTimeExpanded = false
                                    }
                                }) {
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text(timeFormatter.string(from: endDate))
                                            .font(.body1)
                                            .foregroundColor(DS.Colors.Text.netural)
                                            .overlay(
                                                Rectangle()
                                                    .fill(isEndTimeExpanded ? DS.Colors.Neutral.black : DS.Colors.Border.border01)
                                                    .frame(height: isEndTimeExpanded ? 2 : 1)
                                                    .offset(y: 8),
                                                alignment: .bottom
                                            )
                                    }
                                }
                            }
                        }
                    }
                }
                
                if isEndDateExpanded {
                    DatePicker("", selection: $endDate, displayedComponents: [.date])
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                }
                
                if isEndTimeExpanded {
                    DatePicker("", selection: $endDate, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                }
            }
        }
    }
    
    private var temperatureSection: some View {
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
    
    // MARK: - Private Methods
    
    private func setupInitialValues() {
        temperatureText = String(temperature)
        
        // 연차 카테고리인 경우 하루 종일로 기본 설정
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
            // 오전 9시부터 오후 1시까지
            startDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: startDate) ?? startDate
            endDate = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: startDate) ?? endDate
            
        case .afternoonHalf:
            isAllDay = false
            // 오후 1시부터 오후 6시까지
            startDate = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: startDate) ?? startDate
            endDate = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: startDate) ?? endDate
        }
    }
    
    private func saveDetails() {
        if isEditMode {
            if selectedCategory == .vacation {
                print("연차 세부사항 수정 - 연차 유형: \(selectedVacationType.displayName)")
            } else {
                print("일반 세부사항 수정 - 하루 종일: \(isAllDay)")
            }
        } else {
            if selectedCategory == .vacation {
                print("연차 세부사항 저장 - 연차 유형: \(selectedVacationType.displayName)")
            } else {
                print("일반 세부사항 저장 - 하루 종일: \(isAllDay)")
            }
        }
        
        dismiss()
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
