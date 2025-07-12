//
//  CalendarStore.swift
//  CalendarFeature
//
//  Created by Assistant on 7/12/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation
import CalendarDomain
import DesignSystem
import DIContainer
import SwiftUI
import Utils
import Combine

public final class CalendarStore: ObservableObject {
    @Dependency private var calendarUseCase: CalendarUseCaseProtocol
    
    @Published public private(set) var state = CalendarState()
    private let effectSubject = PassthroughSubject<CalendarEffect, Never>()
    
    public var effect: AnyPublisher<CalendarEffect, Never> {
        effectSubject.eraseToAnyPublisher()
    }
    
    public init() {}
    
    public func send(_ intent: CalendarIntent) {
        Task { @MainActor in
            await handle(intent)
        }
    }
    
    @MainActor
    internal func updateState(_ update: (inout CalendarState) -> Void) {
        update(&state)
    }
    
    @MainActor
    private func handle(_ intent: CalendarIntent) async {
        switch intent {
        case .viewDidAppear:
            await handleViewDidAppear()
        case .toggleChanged(let toggle):
            await handleToggleChanged(toggle)
        case .dateSelected(let date):
            await handleDateSelected(date)
        case .categorySelected(let category):
            handleCategorySelected(category)
        case .directInputTapped:
            handleDirectInputTapped()
        case .taskEditRequested(let index):
            handleTaskEditRequested(index)
        case .taskDeleteRequested(let index):
            await handleTaskDeleteRequested(index)
        case .taskTitleChanged(let index, let newTitle):
            await handleTaskTitleChanged(index: index, newTitle: newTitle)
        case .categorySelectionToggled:
            handleCategorySelectionToggled()
        case .scrollOffsetChanged(let offset, let isScrolling):
            handleScrollOffsetChanged(offset: offset, isScrolling: isScrolling)
        }
    }
}

// MARK: - Intent Handlers
private extension CalendarStore {
    @MainActor
    func handleViewDidAppear() async {
        state.scrollOffset = 0
        await loadSchedules()
        updateTodoItemsForSelectedDate()
    }
    
    @MainActor
    func handleToggleChanged(_ toggle: CalendarNavigationBar.ToggleOption) async {
        state.selectedToggle = toggle
        await loadSchedules()
        updateTodoItemsForSelectedDate()
    }
    
    @MainActor
    func handleDateSelected(_ date: Date) async {
        state.selectedDate = date
        await loadSchedules()
        updateTodoItemsForSelectedDate()
    }
    
    @MainActor
    func handleCategorySelected(_ category: TaskCategory) {
        let newTodo = createTodoFromCategory(
            id: state.todoItems.count + 1,
            title: category.name,
            category: category
        )
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            state.todoItems.append(newTodo)
        }
        
        state.editingTaskIndex = state.todoItems.count - 1
        state.showCategorySelection = false
    }
    
    @MainActor
    func handleDirectInputTapped() {
        state.showCategorySelection = false
        effectSubject.send(.navigateToTaskCreate(state.selectedDate))
    }
    
    @MainActor
    func handleTaskEditRequested(_ index: Int) {
        state.showTaskEditSheet = false
        
        guard index < state.todoItems.count else { return }
        let todoItem = state.todoItems[index]
        
        effectSubject.send(.navigateToTaskEdit(
            todoItem.id,
            todoItem.title,
            todoItem.category?.name,
            todoItem.scheduleId,
            state.selectedDate
        ))
    }
    
    @MainActor
    func handleTaskDeleteRequested(_ index: Int) async {
        state.showTaskEditSheet = false
        
        guard index < state.todoItems.count else { return }
        
        let todoItem = state.todoItems[index]
        
        guard let scheduleId = todoItem.scheduleId else {
            state.todoItems.remove(at: index)
            state.selectedTaskIndex = nil
            return
        }
        
        do {
            try await calendarUseCase.deleteSchedule(id: scheduleId)
            state.todoItems.remove(at: index)
            state.selectedTaskIndex = nil
            await loadSchedules()
        } catch {
            effectSubject.send(.showError("일정 삭제에 실패했습니다."))
        }
    }
    
    @MainActor
    func handleTaskTitleChanged(index: Int, newTitle: String) async {
        guard index < state.todoItems.count else { return }
        state.todoItems[index].title = newTitle
    }
    
    @MainActor
    func handleCategorySelectionToggled() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            state.showCategorySelection.toggle()
        }
    }
    
    @MainActor
    func handleScrollOffsetChanged(offset: CGFloat, isScrolling: Bool) {
        state.scrollOffset = offset
        state.isScrolling = isScrolling
    }
}

// MARK: - Business Logic
private extension CalendarStore {
    @MainActor
    func loadSchedules() async {
        state.isLoading = true
        
        do {
            let schedules = try await fetchSchedules()
            state.dailySchedules = schedules
            state.isLoading = false
            updateTodoItemsForSelectedDate()
        } catch {
            state.todoItems = []
            state.isLoading = false
        }
    }
    
    func fetchSchedules() async throws -> [DailySchedule] {
        switch state.selectedToggle {
        case .week:
            let (startDate, endDate) = calculateWeekRange(for: state.selectedDate)
            return try await calendarUseCase.getSchedulesForDateRange(startDate: startDate, endDate: endDate)
        case .month:
            let (startDate, endDate) = calculateMonthRange(for: state.selectedDate)
            return try await calendarUseCase.getSchedulesForDateRange(startDate: startDate, endDate: endDate)
        }
    }
    
    @MainActor
    func updateTodoItemsForSelectedDate() {
        let selectedDateString = state.selectedDate.toString(format: "yyyy-MM-dd")
        
        if let daySchedule = state.dailySchedules.first(where: { $0.date == selectedDateString }) {
            let todoItemsFromAPI = daySchedule.schedules.enumerated().map { index, schedule in
                createTodoFromSchedule(id: index + 1, schedule: schedule)
            }
            state.todoItems = todoItemsFromAPI
        } else {
            state.todoItems = []
        }
    }
    
    func calculateWeekRange(for date: Date) -> (Date, Date) {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return (date, date)
        }
        return (weekInterval.start, calendar.date(byAdding: .day, value: -1, to: weekInterval.end) ?? weekInterval.end)
    }
    
    func calculateMonthRange(for date: Date) -> (Date, Date) {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else {
            return (date, date)
        }
        
        let firstDayOfMonth = monthInterval.start
        let lastDayOfMonth = calendar.date(byAdding: .day, value: -1, to: monthInterval.end) ?? monthInterval.end
        
        guard let firstWeekStart = calendar.dateInterval(of: .weekOfYear, for: firstDayOfMonth)?.start else {
            return (firstDayOfMonth, lastDayOfMonth)
        }
        
        guard let lastWeekInterval = calendar.dateInterval(of: .weekOfYear, for: lastDayOfMonth),
              let lastWeekEnd = calendar.date(byAdding: .day, value: -1, to: lastWeekInterval.end) else {
            return (firstWeekStart, lastDayOfMonth)
        }
        
        return (firstWeekStart, lastWeekEnd)
    }
}

// MARK: - Helper Methods
private extension CalendarStore {
    func createTodoFromSchedule(id: Int, schedule: Schedule) -> DesignSystem.TodoItem {
        let category = DesignSystem.TodoCategory(
            name: schedule.category.displayName,
            color: schedule.category.designSystemColor
        )
        
        return DesignSystem.TodoItem(
            id: id,
            title: schedule.title,
            isCompleted: schedule.completed,
            category: category,
            time: schedule.allDay ? "하루 종일" : schedule.startTime.toString(format: "a h:mm"),
            scheduleId: schedule.id
        )
    }
    
    func createTodoFromCategory(id: Int, title: String, category: TaskCategory, time: String? = nil) -> DesignSystem.TodoItem {
        DesignSystem.TodoItem(
            id: id,
            title: title,
            isCompleted: false,
            category: DesignSystem.TodoCategory(name: category.name, color: category.color),
            time: time,
            scheduleId: nil
        )
    }
}

// MARK: - View Helpers
extension CalendarStore {
    @ViewBuilder
    func calendarCellContent(for date: Date) -> some View {
        let schedulesForDate = getSchedulesForDate(date)
        
        if !schedulesForDate.isEmpty {
            let avgTemperature = calculateAverageTemperature(for: schedulesForDate)
            temperatureImage(avgTemperature)
                .resizable()
                .scaledToFit()
        } else {
            DS.Images.imgFlour
                .resizable()
                .scaledToFit()
        }
    }
    
    private func getSchedulesForDate(_ date: Date) -> [Schedule] {
        let dateString = date.toString(format: "yyyy-MM-dd")
        
        if let daySchedule = state.dailySchedules.first(where: { $0.date == dateString }) {
            return daySchedule.schedules
        }
        
        return []
    }
    
    private func calculateAverageTemperature(for schedules: [Schedule]) -> Int {
        guard !schedules.isEmpty else { return 0 }
        
        let totalTemperature = schedules.reduce(0) { $0 + $1.temperature }
        return totalTemperature / schedules.count
    }
    
    private func temperatureImage(_ temperature: Int) -> Image {
        switch temperature {
        case 0...20: return DS.Images.imgToastNone
        case 21...40: return DS.Images.imgToastDefault
        case 41...60: return DS.Images.imgToastEven
        case 61...80: return DS.Images.imgToastBurn
        case 81...100: return DS.Images.imgToastVacation
        default: return DS.Images.imgFlour
        }
    }
}
