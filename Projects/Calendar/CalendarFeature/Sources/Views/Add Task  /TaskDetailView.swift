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
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var isAllDay = false
    @State private var temperatureText: String = "5"
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
    
    public init(selectedCategory: TaskCreateCategory) {
        self.selectedCategory = selectedCategory
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
                }
                
                if isStartTimeExpanded {
                    DatePicker("", selection: $startDate, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(.wheel)
                        .labelsHidden()
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
                        TextField("5", text: $temperatureText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.leading)
                            .frame(width: 70)
                            .font(.body1)
                            .foregroundColor(DS.Colors.Text.netural)
                            .onChange(of: temperatureText) { _, newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                if let number = Int(filtered), number <= 100 {
                                    temperatureText = filtered
                                } else if filtered.isEmpty {
                                    temperatureText = ""
                                } else {
                                    temperatureText = "100"
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
    
    private func saveDetails() {
        if selectedCategory == .vacation {
            print("연차 세부사항 저장 - 연차 유형: \(selectedVacationType.displayName)")
        } else {
            print("일반 세부사항 저장 - 하루 종일: \(isAllDay)")
        }
        dismiss()
    }
}

#Preview {
    TaskDetailView(selectedCategory: .company)
}
