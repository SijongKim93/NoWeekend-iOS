//
//  CalendarView.swift
//  CalendarFeature
//
//  Created by 이지훈 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import CalendarDomain
import DesignSystem
import Utils
import DIContainer
import SwiftUI

public struct CalendarView: View {
    @Dependency private var calendarUseCase: CalendarUseCaseProtocol

    @State private var selectedDate = Date()
    @State private var selectedToggle: CalendarNavigationBar.ToggleOption = .week
    @State private var dailySchedules: [DailySchedule] = []
    
    @State private var showDatePicker = false
    @State private var showTaskEditSheet = false
    @State private var showCategorySelection = false
    @State private var scrollOffset: CGFloat = 0
    @State private var isScrolling = false
    
    @State private var selectedTaskIndex: Int?
    @State private var editingTaskIndex: Int? = nil
    @State private var todoItems = TodoItem.mockData
    
    @State private var isLoading = false
    @State private var isDeletingSchedule = false
    @State private var isUpdatingSchedule = false  // ← 수정 중 상태
    @State private var errorMessage: String?
    
    private var isFloatingButtonExpanded: Bool {
        scrollOffset == 0 && !isScrolling
    }
    
    public init() {}
    
    public var body: some View {
        ZStack {
            mainContent
            overlayContent
            floatingButton
        }
        .sheet(isPresented: $showDatePicker) {
            DatePickerWithLabelBottomSheet(selectedDate: $selectedDate)
        }
        .sheet(isPresented: $showTaskEditSheet) {
            TaskEditBottomSheet(
                onEditAction: handleTaskEdit,
                onTomorrowAction: handleTomorrowAction,
                onDeleteAction: handleDeleteAction,
                isPresented: $showTaskEditSheet
            )
        }
        .task {
            await initializeView()
        }
    }
}

// MARK: - View Components
private extension CalendarView {
    var mainContent: some View {
        VStack(spacing: 0) {
            CalendarNavigationBar(
                dateText: formatSelectedDate(selectedDate),
                onDateTapped: { showDatePicker = true },
                onToggleChanged: handleToggleChange
            )
            
            CalendarSection(
                selectedDate: selectedDate,
                selectedToggle: selectedToggle,
                onDateTap: handleDateTap,
                calendarCellContent: calendarCellContent
            )
            
            contentSection
        }
        .background(.white)
    }
    
    @ViewBuilder
    var contentSection: some View {
        if selectedToggle == .week {
            TodoScrollSection(
                todoItems: $todoItems,
                selectedTaskIndex: $selectedTaskIndex,
                showTaskEditSheet: $showTaskEditSheet,
                scrollOffset: $scrollOffset,
                isScrolling: $isScrolling,
                editingTaskIndex: $editingTaskIndex,
                onTitleChanged: { index, newTitle in
                    Task {
                        await updateTodoTitle(index: index, newTitle: newTitle)
                    }
                }
            )
            .background(.white)
        } else {
            Spacer()
                .background(.white)
        }
    }
    
    @ViewBuilder
    var overlayContent: some View {
        if showCategorySelection {
            TaskCategorySelectionView(
                isPresented: $showCategorySelection,
                onCategorySelected: handleCategorySelection
            )
            .zIndex(1)
        }
    }
    
    var floatingButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                FloatingAddButton(
                    isExpanded: isFloatingButtonExpanded,
                    isShowingCategory: showCategorySelection,
                    action: showCategorySelectionWithAnimation,
                    dismissAction: hideCategorySelectionWithAnimation
                )
                .padding(.trailing, 20)
                .padding(.bottom, 33)
            }
        }
        .zIndex(4)
    }
}

// MARK: - Event Handlers
private extension CalendarView {
    func handleToggleChange(_ toggle: CalendarNavigationBar.ToggleOption) {
        selectedToggle = toggle
        Task { await loadSchedules() }
    }
    
    func handleDateTap(_ date: Date) {
        selectedDate = date
        Task { await loadSchedules() }
    }
    
    func handleTaskEdit() {
        showTaskEditSheet = false
        
        if let index = selectedTaskIndex {
            editingTaskIndex = index
        }
    }
    
    func handleTomorrowAction() {
        showTaskEditSheet = false
        // TODO: 내일 또 하기 로직 구현
    }
    
    func handleDeleteAction() {
        showTaskEditSheet = false
        
        if let index = selectedTaskIndex {
            todoItems.remove(at: index)
            selectedTaskIndex = nil
        }
        
        if let schedule = getFirstAvailableSchedule() {
            Task { await deleteSchedule(id: schedule.id) }
        }
    }
    
    func handleCategorySelection(_ category: TaskCategory) {
        let newTodo = TodoItem.create(
            id: todoItems.count + 1,
            title: "새로운 \(category.name)",
            category: category
        )
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            todoItems.append(newTodo)
        }
        
        showCategorySelection = false
    }
    
    func showCategorySelectionWithAnimation() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showCategorySelection = true
        }
    }
    
    func hideCategorySelectionWithAnimation() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showCategorySelection = false
        }
    }
}

// MARK: - Data Operations
private extension CalendarView {
    func initializeView() async {
        scrollOffset = 0
        await loadSchedules()
    }
    
    func loadSchedules() async {
        isLoading = true
        errorMessage = nil
        
        do {
            dailySchedules = try await fetchSchedules()
            logScheduleData()
        } catch {
            handleScheduleLoadError(error)
        }
        
        isLoading = false
    }
    
    func fetchSchedules() async throws -> [DailySchedule] {
        switch selectedToggle {
        case .week:
            return try await calendarUseCase.getWeeklySchedules(for: selectedDate)
        case .month:
            return try await calendarUseCase.getMonthlySchedules(for: selectedDate)
        }
    }
    
    // ✅ API 연결된 할일 제목 수정 함수
    func updateTodoTitle(index: Int, newTitle: String) async {
        guard index < todoItems.count else { return }
        
        // 일단 로컬 상태 업데이트
        let originalTitle = todoItems[index].title
        todoItems[index].title = newTitle
        
        // 해당 할일에 연결된 스케줄 ID 찾기
        if let scheduleId = getScheduleIdForTodo(at: index) {
            isUpdatingSchedule = true
            
            do {
                let todo = todoItems[index]
                let schedule = getScheduleForTodo(at: index)
                
                let updatedSchedule = try await calendarUseCase.updateSchedule(
                    id: scheduleId,
                    title: newTitle,
                    startTime: schedule?.startTime ?? Date(),
                    endTime: schedule?.endTime ?? Date(),
                    category: schedule?.category ?? .other,
                    temperature: schedule?.temperature ?? 3,
                    allDay: schedule?.allDay ?? false,
                    alarmOption: schedule?.alarmOption ?? .none
                )
                
                print("✅ 할일 제목 수정 성공: \(newTitle)")
                
                // 일정 목록 새로고침
                await loadSchedules()
                
            } catch {
                print("❌ 할일 제목 수정 실패: \(error)")
                
                // 실패 시 원래 제목으로 되돌리기
                todoItems[index].title = originalTitle
                errorMessage = "할일 수정에 실패했습니다: \(error.localizedDescription)"
            }
            
            isUpdatingSchedule = false
        } else {
            print("⚠️ 할일에 연결된 스케줄 ID를 찾을 수 없습니다.")
        }
    }
    
    func deleteSchedule(id: String) async {
        isDeletingSchedule = true
        
        do {
            try await calendarUseCase.deleteSchedule(id: id)
            await loadSchedules()
        } catch {
            print("일정 삭제 실패: \(error)")
        }
        
        isDeletingSchedule = false
    }
    
    // 할일 인덱스로 스케줄 ID 찾기 (임시 구현)
    func getScheduleIdForTodo(at index: Int) -> String? {
        // 실제로는 TodoItem에 scheduleId가 있어야 함
        // 지금은 임시로 첫 번째 스케줄 ID 사용
        return getFirstAvailableSchedule()?.id
    }
    
    // 할일 인덱스로 스케줄 객체 찾기 (임시 구현)
    func getScheduleForTodo(at index: Int) -> Schedule? {
        return getFirstAvailableSchedule()
    }
}

// MARK: - Helper Functions
private extension CalendarView {
    func getFirstAvailableSchedule() -> Schedule? {
        let allSchedules = dailySchedules.flatMap { $0.schedules }
        return allSchedules.first
    }
    
    @ViewBuilder
    func calendarCellContent(for date: Date) -> some View {
        let schedulesForDate = getSchedulesForDate(date)
        
        if !schedulesForDate.isEmpty {
            DS.Images.imgToastDefault
                .resizable()
                .scaledToFit()
        } else {
            DS.Images.imgFlour
                .resizable()
                .scaledToFit()
        }
    }
    
    func getSchedulesForDate(_ date: Date) -> [Schedule] {
        let dateString = date.toString(format: "yyyy-MM-dd")
        return dailySchedules
            .first { $0.date == dateString }?
            .schedules ?? []
    }
    
    func formatSelectedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: date)
    }
    
    func logScheduleData() {
        let totalSchedules = dailySchedules.flatMap { $0.schedules }.count
        print("📅 로드된 일정 수: \(totalSchedules)개")
    }
    
    func handleScheduleLoadError(_ error: Error) {
        errorMessage = "일정을 불러오는데 실패했습니다: \(error.localizedDescription)"
        print("일정 로드 실패: \(error)")
    }
}

// MARK: - TodoItem Extensions
private extension TodoItem {
    static var mockData: [TodoItem] {
        [
            TodoItem(id: 1, title: "할 일 제목이 들어갑니다.", isCompleted: false, category: DesignSystem.TodoCategory(name: "회사", color: DS.Colors.TaskItem.orange), time: "오전 10:00"),
            TodoItem(id: 2, title: "할 일 제목이 들어갑니다.", isCompleted: false, category: DesignSystem.TodoCategory(name: "회사", color: DS.Colors.TaskItem.orange), time: "오전 10:00"),
            TodoItem(id: 3, title: "할 일 제목이 들어갑니다.", isCompleted: false, category: DesignSystem.TodoCategory(name: "회사", color: DS.Colors.TaskItem.orange), time: "오전 10:00"),
            TodoItem(id: 4, title: "할 일 제목이 들어갑니다.", isCompleted: false, category: DesignSystem.TodoCategory(name: "회사", color: DS.Colors.TaskItem.orange), time: "오전 10:00"),
            TodoItem(id: 5, title: "할 일 제목이 들어갑니다.", isCompleted: false, category: DesignSystem.TodoCategory(name: "회사", color: DS.Colors.TaskItem.orange), time: "오전 10:00")
        ]
    }
    
    static func create(id: Int, title: String, category: TaskCategory, time: String? = nil) -> TodoItem {
        TodoItem(
            id: id,
            title: title,
            isCompleted: false,
            category: DesignSystem.TodoCategory(name: category.name, color: category.color),
            time: time
        )
    }
}

// MARK: - TaskCategory 타입 정의
public struct TaskCategory {
    public let name: String
    public let color: Color
    
    public init(name: String, color: Color) {
        self.name = name
        self.color = color
    }
}

#Preview {
    CalendarView()
}
