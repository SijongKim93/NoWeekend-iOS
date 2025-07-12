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
    @EnvironmentObject private var coordinator: CalendarCoordinator

    @State private var selectedDate = Date()
    @State private var selectedToggle: CalendarNavigationBar.ToggleOption = .week
    @State private var dailySchedules: [DailySchedule] = []
    
    @State private var showDatePicker = false
    @State private var showTaskEditSheet = false
    @State private var showCategorySelection = false
    @State private var scrollOffset: CGFloat = 0
    @State private var isScrolling = false
    
    @State private var selectedTaskIndex: Int?
    @State private var editingTaskIndex: Int?
    @State private var todoItems: [TodoItem] = []
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var previousSelectedDate: Date?
    
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
                .onAppear {
                    previousSelectedDate = selectedDate
                }
        }
        .sheet(isPresented: $showTaskEditSheet) {
            TaskEditBottomSheet(
                onEditAction: handleTaskEdit,
                onTomorrowAction: handleTomorrowAction,
                onDeleteAction: handleDeleteAction,
                isPresented: $showTaskEditSheet
            )
        }
        .onChange(of: selectedDate) { oldValue, newValue in
            if let previous = previousSelectedDate,
               !Calendar.current.isDate(newValue, equalTo: previous, toGranularity: .month) {
                Task {
                    await loadSchedules()
                    await MainActor.run {
                        updateTodoItemsForSelectedDate()
                    }
                }
            } else if !Calendar.current.isDate(newValue, inSameDayAs: oldValue) {
                Task {
                    await MainActor.run {
                        updateTodoItemsForSelectedDate()
                    }
                }
            }
            previousSelectedDate = nil
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
                dateText: selectedDate.toString(format: "yyyy년 M월"),
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
            if isLoading {
                VStack {
                    ProgressView("일정을 불러오는 중...")
                        .padding()
                    Spacer()
                }
                .background(.white)
            } else {
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
            }
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
                onCategorySelected: handleCategorySelection,
                onDirectInputTapped: handleDirectInput
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
        Task {
            await loadSchedules()
            await MainActor.run {
                updateTodoItemsForSelectedDate()
            }
        }
    }
    
    func handleDateTap(_ date: Date) {
        selectedDate = date
        Task {
            await loadSchedules()
            await MainActor.run {
                updateTodoItemsForSelectedDate()
            }
        }
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
    }
    
    func handleCategorySelection(_ category: TaskCategory) {
        let newTodo = TodoItem.createFromCategory(
            id: todoItems.count + 1,
            title: category.name,
            category: category
        )
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            todoItems.append(newTodo)
        }
        
        editingTaskIndex = todoItems.count - 1
        showCategorySelection = false
    }
    
    func handleDirectInput() {
        showCategorySelection = false
        coordinator.push(.taskCreate)
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
        await MainActor.run {
            updateTodoItemsForSelectedDate()
        }
    }
    
    func loadSchedules() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let schedules = try await fetchSchedules()
            await MainActor.run {
                dailySchedules = schedules
                isLoading = false
                updateTodoItemsForSelectedDate()
            }
        } catch {
            await MainActor.run {
                handleScheduleLoadError(error)
                isLoading = false
            }
        }
    }
    
    func fetchSchedules() async throws -> [DailySchedule] {
        switch selectedToggle {
        case .week:
            let (startDate, endDate) = calculateWeekRange(for: selectedDate)
            return try await calendarUseCase.getSchedulesForDateRange(startDate: startDate, endDate: endDate)
        case .month:
            let (startDate, endDate) = calculateMonthRange(for: selectedDate)
            return try await calendarUseCase.getSchedulesForDateRange(startDate: startDate, endDate: endDate)
        }
    }
    
    private func calculateWeekRange(for date: Date) -> (Date, Date) {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return (date, date)
        }
        return (weekInterval.start, calendar.date(byAdding: .day, value: -1, to: weekInterval.end) ?? weekInterval.end)
    }
    
    private func calculateMonthRange(for date: Date) -> (Date, Date) {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else {
            return (date, date)
        }
        
        let firstDayOfMonth = monthInterval.start
        let lastDayOfMonth = calendar.date(byAdding: .day, value: -1, to: monthInterval.end) ?? monthInterval.end
        
        // 첫째 주의 시작 (월요일)
        guard let firstWeekStart = calendar.dateInterval(of: .weekOfYear, for: firstDayOfMonth)?.start else {
            return (firstDayOfMonth, lastDayOfMonth)
        }
        
        // 마지막 주의 끝 (일요일)
        guard let lastWeekInterval = calendar.dateInterval(of: .weekOfYear, for: lastDayOfMonth),
              let lastWeekEnd = calendar.date(byAdding: .day, value: -1, to: lastWeekInterval.end) else {
            return (firstWeekStart, lastDayOfMonth)
        }
        
        return (firstWeekStart, lastWeekEnd)
    }
    
    func updateTodoItemsForSelectedDate() {
        let selectedDateString = selectedDate.toString(format: "yyyy-MM-dd")
        
        if let daySchedule = dailySchedules.first(where: { $0.date == selectedDateString }) {
            let todoItemsFromAPI = daySchedule.schedules.enumerated().map { index, schedule in
                TodoItem.createFromSchedule(id: index + 1, schedule: schedule)
            }
            todoItems = todoItemsFromAPI
        } else {
            todoItems = []
        }
    }
    
    func updateTodoTitle(index: Int, newTitle: String) async {
        guard index < todoItems.count else { return }
        todoItems[index].title = newTitle
        
        // TODO: 실제 일정 업데이트 API 호출
    }
    
    func handleScheduleLoadError(_ error: Error) {
        errorMessage = "일정을 불러오는데 실패했습니다: \(error.localizedDescription)"
        todoItems = []
    }
}

// MARK: - Helper Functions
private extension CalendarView {
    @ViewBuilder
    func calendarCellContent(for date: Date) -> some View {
        let schedulesForDate = getSchedulesForDate(date)
        let daySchedule = getDaySchedule(for: date)
        
        if !schedulesForDate.isEmpty {
            let temperature = daySchedule?.dailyTemperature ?? 0
            let imageToShow = (temperature == 0 && !schedulesForDate.isEmpty) ?
                DS.Images.imgToastDefault : temperatureImage(temperature)
            
            imageToShow
                .resizable()
                .scaledToFit()
        } else {
            DS.Images.imgFlour
                .resizable()
                .scaledToFit()
        }
    }
    
    func getDaySchedule(for date: Date) -> DailySchedule? {
        let dateString = date.toString(format: "yyyy-MM-dd")
        return dailySchedules.first { $0.date == dateString }
    }
    
    func getSchedulesForDate(_ date: Date) -> [Schedule] {
        return getDaySchedule(for: date)?.schedules ?? []
    }
    
    // TODO: 온도 얼만데!
    func temperatureImage(_ temperature: Int) -> Image {
        switch temperature {
        case 0...20: return DS.Images.imgFlour
        case 21...40: return DS.Images.imgToastNone
        case 41...60: return DS.Images.imgToastDefault
        case 61...80: return DS.Images.imgToastEven
        case 81...100: return DS.Images.imgToastBurn
        default: return DS.Images.imgFlour
        }
    }
}

// MARK: - TodoItem Extensions
private extension TodoItem {
    static func createFromSchedule(id: Int, schedule: Schedule) -> TodoItem {
        let category = DesignSystem.TodoCategory(
            name: schedule.category.displayName,
            color: schedule.category.designSystemColor
        )
        
        return TodoItem(
            id: id,
            title: schedule.title,
            isCompleted: schedule.completed,
            category: category,
            time: schedule.allDay ? "하루 종일" : schedule.startTime.toString(format: "a h:mm")
        )
    }
    
    static func createFromCategory(id: Int, title: String, category: TaskCategory, time: String? = nil) -> TodoItem {
        TodoItem(
            id: id,
            title: title,
            isCompleted: false,
            category: DesignSystem.TodoCategory(name: category.name, color: category.color),
            time: time
        )
    }
}

// MARK: - ScheduleCategory Extension
private extension ScheduleCategory {
    var designSystemColor: Color {
        switch self {
        case .company: return DS.Colors.TaskItem.green
        case .personal: return DS.Colors.TaskItem.orange
        case .health, .education, .travel: return DS.Colors.TaskItem.purple
        case .social: return DS.Colors.TaskItem.orange
        case .other: return DS.Colors.TaskItem.etc
        }
    }
}

#Preview {
    CalendarCoordinatorView()
}
