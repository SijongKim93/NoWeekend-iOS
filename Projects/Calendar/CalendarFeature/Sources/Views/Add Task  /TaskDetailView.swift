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
    @EnvironmentObject private var coordinator: CalendarCoordinator
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var isAllDay = false
    @State private var selectedAlarm: AlarmOption = .none
    @State private var temperatureText: String = "5"
    
    @State private var isStartDateExpanded = false
    @State private var isEndDateExpanded = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView {
                VStack(spacing: 0) {
                    dateSection
                    temperatureSection
                }
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
                coordinator.pop()
            },
            onSaveTapped: {
                saveDetails()
            }
        )
    }
    
    private var dateSection: some View {
        VStack(spacing: 0) {
            DetailSettingRowWithoutDivider(
                title: "하루 종일",
                content: {
                    Toggle("", isOn: $isAllDay)
                        .labelsHidden()
                        .onChange(of: isAllDay) { _ in
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                isStartDateExpanded = false
                                isEndDateExpanded = false
                            }
                        }
                }
            )
            
            VStack(spacing: 0) {
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                        isStartDateExpanded.toggle()
                        if isStartDateExpanded {
                            isEndDateExpanded = false
                        }
                    }
                }) {
                    HStack {
                        Text("시작")
                            .font(.body1)
                            .foregroundColor(DS.Colors.Text.netural)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            HStack(spacing: 8) {
                                Text(dateFormatter.string(from: startDate))
                                    .font(.body1)
                                    .foregroundColor(DS.Colors.Text.netural)
                                
                                if !isAllDay {
                                    Text(timeFormatter.string(from: startDate))
                                        .font(.body1)
                                        .foregroundColor(DS.Colors.Text.netural)
                                }
                            }
                            
                            Rectangle()
                                .fill(DS.Colors.Border.border01)
                                .frame(height: 1)
                                .frame(width: 120)
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .contentShape(Rectangle())
                }
                
                if isStartDateExpanded {
                    DatePicker(
                        "",
                        selection: $startDate,
                        displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.95).combined(with: .opacity).combined(with: .move(edge: .top)),
                        removal: .scale(scale: 0.95).combined(with: .opacity).combined(with: .move(edge: .top))
                    ))
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0), value: isStartDateExpanded)
            
            VStack(spacing: 0) {
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                        isEndDateExpanded.toggle()
                        if isEndDateExpanded {
                            isStartDateExpanded = false
                        }
                    }
                }) {
                    HStack {
                        Text("종료")
                            .font(.body1)
                            .foregroundColor(DS.Colors.Text.netural)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            HStack(spacing: 8) {
                                Text(dateFormatter.string(from: endDate))
                                    .font(.body1)
                                    .foregroundColor(DS.Colors.Text.netural)
                                
                                if !isAllDay {
                                    Text(timeFormatter.string(from: endDate))
                                        .font(.body1)
                                        .foregroundColor(DS.Colors.Text.netural)
                                }
                            }
                            
                            Rectangle()
                                .fill(DS.Colors.Border.border01)
                                .frame(height: 1)
                                .frame(width: 120)
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .contentShape(Rectangle())
                }
                
                if isEndDateExpanded {
                    DatePicker(
                        "",
                        selection: $endDate,
                        displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.95).combined(with: .opacity).combined(with: .move(edge: .top)),
                        removal: .scale(scale: 0.95).combined(with: .opacity).combined(with: .move(edge: .top))
                    ))
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0), value: isEndDateExpanded)
        }
    }
    
    private var temperatureSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("열정 온도")
                    .font(.body1)
                    .foregroundColor(DS.Colors.Text.netural)
                
                Spacer()
                
                HStack(spacing: 4) {
                    TextField("5", text: $temperatureText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 40)
                        .font(.body1)
                        .foregroundColor(DS.Colors.Text.netural)
                        .onChange(of: temperatureText) { newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            if let number = Int(filtered), number <= 100 {
                                temperatureText = filtered
                            } else if filtered.isEmpty {
                                temperatureText = ""
                            } else {
                                temperatureText = "100"
                            }
                        }
                    
                    Text("°C")
                        .font(.body1)
                        .foregroundColor(DS.Colors.Text.netural)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            
            HStack {
                Text("0 ~ 100°C 범위")
                    .font(.body3)
                    .foregroundColor(DS.Colors.Text.disable)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
    }
    
    private func saveDetails() {
        print("세부사항 저장")
        coordinator.pop()
    }
}

struct DetailSettingRowWithoutDivider<Content: View>: View {
    let title: String
    let content: () -> Content
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body1)
                .foregroundColor(DS.Colors.Text.netural)
            
            Spacer()
            
            content()
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
    }
}

enum AlarmOption: String, CaseIterable {
    case none = "NONE"
    case fiveMinutesBefore = "FIVE_MINUTES_BEFORE"
    case fifteenMinutesBefore = "FIFTEEN_MINUTES_BEFORE"
    case thirtyMinutesBefore = "THIRTY_MINUTES_BEFORE"
    case oneHourBefore = "ONE_HOUR_BEFORE"
    case oneDayBefore = "ONE_DAY_BEFORE"
    
    var displayName: String {
        switch self {
        case .none: return "없음"
        case .fiveMinutesBefore: return "5분 전"
        case .fifteenMinutesBefore: return "15분 전"
        case .thirtyMinutesBefore: return "30분 전"
        case .oneHourBefore: return "1시간 전"
        case .oneDayBefore: return "1일 전"
        }
    }
}

#Preview {
    NavigationView {
        TaskDetailView()
            .environmentObject(CalendarCoordinator())
    }
}
