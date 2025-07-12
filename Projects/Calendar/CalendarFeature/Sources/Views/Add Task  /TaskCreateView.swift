//
//  TaskCreateView.swift
//  CalendarFeature
//
//  Created by 이지훈 on 7/9/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import DesignSystem
import SwiftUI
import CalendarDomain
import DIContainer

public struct TaskCreateView: View {
    @EnvironmentObject var coordinator: CalendarCoordinator
    @Dependency private var calendarUseCase: CalendarUseCaseProtocol
    
    private let editingTodoId: Int?
    private let editingTitle: String?
    private let editingCategory: String?
    private let editingScheduleId: String?
    private let isEditMode: Bool
    private let selectedDate: Date
    
    @State private var selectedCategory: TaskCreateCategory = .company
    @State private var title: String = ""
    @State private var titleError: String?
    @State private var showTaskDetail = false
    @State private var isLoading = false
    
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
    @State private var isAllDay = false
    @State private var temperature = 50
    
    private let categories: [TaskCreateCategory] = [.company, .personal, .other, .vacation]
    
    public init(selectedDate: Date = Date()) {
        self.editingTodoId = nil
        self.editingTitle = nil
        self.editingCategory = nil
        self.editingScheduleId = nil
        self.isEditMode = false
        self.selectedDate = selectedDate
    }
    
    public init(
        editingTodoId: Int,
        editingTitle: String,
        editingCategory: String?,
        editingScheduleId: String?,
        selectedDate: Date = Date()
    ) {
        self.editingTodoId = editingTodoId
        self.editingTitle = editingTitle
        self.editingCategory = editingCategory
        self.editingScheduleId = editingScheduleId
        self.isEditMode = true
        self.selectedDate = selectedDate
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            if isLoading {
                VStack {
                    ProgressView(isEditMode ? "수정 중..." : "저장 중...")
                        .padding()
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(spacing: 32) {
                        categorySection
                        titleSection
                        detailSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }
            }
            
            Spacer()
        }
        .background(DS.Colors.Background.normal)
        .navigationDestination(isPresented: $showTaskDetail) {
            TaskDetailView(
                selectedCategory: selectedCategory,
                startDate: $startDate,
                endDate: $endDate,
                isAllDay: $isAllDay,
                temperature: $temperature,
                isEditMode: isEditMode
            )
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            setupInitialValues()
        }
    }
    
    private var navigationBar: some View {
        CustomNavigationBar(
            type: .cancelWithLabelAndSave(isEditMode ? "할 일 수정" : "할 일 추가"),
            onCancelTapped: {
                coordinator.pop()
            },
            onSaveTapped: {
                Task {
                    await saveTask()
                }
            }
        )
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(DS.Colors.Background.alternative01)
                    .frame(height: 42)
                
                GeometryReader { geometry in
                    let segmentWidth = geometry.size.width / CGFloat(categories.count)
                    let selectedIndex = categories.firstIndex(of: selectedCategory) ?? 0
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .stroke(selectedCategory.color, lineWidth: 1)
                        .frame(width: segmentWidth - 4, height: 34)
                        .offset(x: CGFloat(selectedIndex) * segmentWidth + 2, y: 4)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedCategory)
                }
                .frame(height: 42)
                
                HStack(spacing: 0) {
                    ForEach(categories, id: \.self) { category in
                        CategorySegmentButton(
                            category: category,
                            isSelected: selectedCategory == category,
                            onTap: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    selectedCategory = category
                                }
                            }
                        )
                    }
                }
            }
            .frame(height: 44)
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading) {
            NWTextField.todoMultiLine(
                text: $title,
                placeholder: "제목",
                errorMessage: $titleError
            )
        }
    }
    
    private var detailSection: some View {
        VStack(spacing: 30) {
            DetailRowButton(
                title: "세부사항",
                onTap: {
                    showTaskDetail = true
                }
            )
        }
    }
    
    // MARK: - Private Methods
    
    private func setupInitialValues() {
        let calendar = Calendar.current
        startDate = calendar.startOfDay(for: selectedDate)
        endDate = calendar.date(byAdding: .hour, value: 1, to: startDate) ?? startDate
       
        guard isEditMode else { return }
        
        if let editingTitle = editingTitle {
            title = editingTitle
        }
        
        if let categoryName = editingCategory {
            selectedCategory = mapCategoryNameToTaskCreateCategory(categoryName)
        }
    }
    
    private func mapCategoryNameToTaskCreateCategory(_ categoryName: String) -> TaskCreateCategory {
        switch categoryName {
        case "회사":
            return .company
        case "개인":
            return .personal
        case "연차":
            return .vacation
        case "기타":
            return .other
        default:
            return .other
        }
    }
    
    private func mapTaskCreateCategoryToScheduleCategory(_ category: TaskCreateCategory) -> ScheduleCategory {
        switch category {
        case .company:
            return .company
        case .personal:
            return .personal
        case .vacation:
            return .leave
        case .other:
            return .etc
        }
    }
    
    private func saveTask() async {
        guard !title.isEmpty else {
            await MainActor.run {
                titleError = "제목을 입력해주세요"
            }
            return
        }
        
        await MainActor.run {
            titleError = nil
            isLoading = true
        }
        
        do {
            let scheduleCategory = mapTaskCreateCategoryToScheduleCategory(selectedCategory)
            
            let calendar = Calendar.current
            let dateOnly = calendar.startOfDay(for: selectedDate)
            
            if isEditMode {
                guard let scheduleId = editingScheduleId else {
                    print("❌ 수정할 일정 ID가 없습니다")
                    await MainActor.run {
                        titleError = "수정할 일정을 찾을 수 없습니다"
                        isLoading = false
                    }
                    return
                }
                
                let _ = try await calendarUseCase.updateSchedule(
                    id: scheduleId,
                    title: title,
                    startTime: startDate,
                    endTime: endDate,
                    category: scheduleCategory,
                    temperature: temperature,
                    allDay: isAllDay,
                    alarmOption: .none
                )
                
                print("✅ 할 일 수정 완료: \(title)")
            } else {
              
                let _ = try await calendarUseCase.createSchedule(
                    title: title,
                    date: dateOnly,
                    startTime: startDate,
                    endTime: endDate,
                    category: scheduleCategory,
                    temperature: temperature,
                    allDay: isAllDay,
                    alarmOption: .none
                )
                
                print("✅ 할 일 생성 완료: \(title)")
            }
            
            await MainActor.run {
                coordinator.pop()
            }
        } catch {
            await MainActor.run {
                print("❌ 할 일 저장 실패: \(error)")
                if let decodingError = error as? DecodingError {
                    print("📋 디코딩 오류 상세: \(decodingError)")
                }
                titleError = "저장에 실패했습니다. 다시 시도해주세요."
                isLoading = false
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
}

struct CategorySegmentButton: View {
    let category: TaskCreateCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(category.displayName)
                .font(.body2)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? category.color : DS.Colors.Text.netural)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .contentShape(Rectangle())
        }
    }
}

struct DetailRowButton: View {
    let title: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .font(.body1)
                    .foregroundColor(DS.Colors.Text.netural)
                
                Spacer()
                
                DS.Images.icnChevronRight
                    .foregroundColor(DS.Colors.Neutral.gray500)
            }
            .background(DS.Colors.Background.normal)
        }
    }
}

#Preview {
    NavigationStack {
        TaskCreateView()
            .environmentObject(CalendarCoordinator())
    }
}
