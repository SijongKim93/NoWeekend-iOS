//
//  DateDetailView.swift
//  CalendarFeature
//
//  Created by 이지훈 on 7/13/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import CalendarDomain
import DesignSystem
import DIContainer
import SwiftUI
import Utils

public struct DateDetailView: View {
    @EnvironmentObject private var coordinator: CalendarCoordinator
    @Dependency private var calendarUseCase: CalendarUseCaseProtocol
    
    let selectedDate: Date
    
    @State private var schedules: [Schedule] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 EEEE"
        return formatter
    }()
    
    public init(selectedDate: Date) {
        self.selectedDate = selectedDate
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            if isLoading {
                VStack {
                    ProgressView("일정을 불러오는 중...")
                        .padding()
                    Spacer()
                }
            } else if let errorMessage = errorMessage {
                VStack {
                    Text("오류: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                    Spacer()
                }
            } else {
                contentView
            }
        }
        .background(DS.Colors.Background.normal)
        .navigationBarHidden(true)
        .task {
            await loadSchedules()
        }
    }
    
    private var navigationBar: some View {
        CustomNavigationBar(
            type: .backWithLabel(dateFormatter.string(from: selectedDate)),
            onBackTapped: {
                coordinator.pop()
            }
        )
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 날짜 정보
                VStack(alignment: .leading, spacing: 8) {
                    Text(dateFormatter.string(from: selectedDate))
                        .font(.heading3)
                        .foregroundColor(DS.Colors.Text.netural)
                    
                    Text("일정 \(schedules.count)개")
                        .font(.body2)
                        .foregroundColor(DS.Colors.Text.disable)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // 일정 목록
                if schedules.isEmpty {
                    VStack(spacing: 16) {
                        DS.Images.imgFlour
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                        
                        Text("이 날의 일정이 없습니다")
                            .font(.body1)
                            .foregroundColor(DS.Colors.Text.disable)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(schedules, id: \.id) { schedule in
                            ScheduleRowView(schedule: schedule)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 100)
            }
        }
    }
}

struct ScheduleRowView: View {
    let schedule: Schedule
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // 카테고리 색상 인디케이터
                Circle()
                    .fill(categoryColor)
                    .frame(width: 8, height: 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(schedule.title)
                        .font(.body1)
                        .foregroundColor(DS.Colors.Text.netural)
                    
                    HStack(spacing: 8) {
                        Text(schedule.category.displayName)
                            .font(.body3)
                            .foregroundColor(categoryColor)
                        
                        Rectangle()
                            .fill(DS.Colors.Border.border02)
                            .frame(width: 2, height: 12)
                        
                        Text(timeText)
                            .font(.body2)
                            .foregroundColor(DS.Colors.Text.body)
                        
                        if schedule.temperature > 0 {
                            Rectangle()
                                .fill(DS.Colors.Border.border02)
                                .frame(width: 2, height: 12)
                            
                            Text("\(schedule.temperature)°C")
                                .font(.body2)
                                .foregroundColor(DS.Colors.Text.body)
                        }
                    }
                }
                
                Spacer()
                
                if schedule.completed {
                    DS.Images.icnChecked
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 4)
            
            Rectangle()
                .fill(DS.Colors.Border.border01)
                .frame(height: 1)
        }
    }
    
    private var categoryColor: Color {
        switch schedule.category {
        case .company: return DS.Colors.TaskItem.green
        case .personal: return DS.Colors.TaskItem.orange
        case .etc: return DS.Colors.TaskItem.etc
        case .leave: return DS.Colors.TaskItem.etc
        
        }
    }
    
    private var timeText: String {
        if schedule.allDay {
            return "하루 종일"
        } else {
            let startTime = timeFormatter.string(from: schedule.startTime)
            let endTime = timeFormatter.string(from: schedule.endTime)
            return "\(startTime) - \(endTime)"
        }
    }
}

// MARK: - Data Loading
private extension DateDetailView {
    func loadSchedules() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let dateString = selectedDate.toString(format: "yyyy-MM-dd")
            print("🗓️ 날짜 디테일 로딩 - 선택된 날짜: \(dateString)")
            
            let dailySchedules = try await calendarUseCase.getSchedulesForDateRange(
                startDate: selectedDate,
                endDate: selectedDate
            )
            
            print("📋 API로부터 받은 일정 수: \(dailySchedules.count)")
            
            if let daySchedule = dailySchedules.first(where: { $0.date == dateString }) {
                let schedulesForDay = daySchedule.schedules
                print("📅 \(dateString)의 일정: \(schedulesForDay.count)개")
                
                for (index, schedule) in schedulesForDay.enumerated() {
                    print("📌 일정 \(index + 1): ID=\(schedule.id), 제목=\(schedule.title), 카테고리=\(schedule.category.displayName)")
                }
                
                await MainActor.run {
                    self.schedules = schedulesForDay
                    self.isLoading = false
                }
            } else {
                print("❌ \(dateString)에 해당하는 일정을 찾을 수 없습니다")
                await MainActor.run {
                    self.schedules = []
                    self.isLoading = false
                }
            }
            
        } catch {
            print("❌ 일정 로딩 실패: \(error.localizedDescription)")
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

#Preview {
    NavigationStack {
        DateDetailView(selectedDate: Date())
            .environmentObject(CalendarCoordinator())
    }
}
