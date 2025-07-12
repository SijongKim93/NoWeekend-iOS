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

// MARK: - Intent (사용자 액션)
public enum CalendarIntent {
    case viewDidAppear
    case toggleChanged(CalendarNavigationBar.ToggleOption)
    case dateSelected(Date)
    case datePicker(isPresented: Bool, previousDate: Date?)
    case categorySelected(TaskCategory)
    case directInputTapped
    case taskEditRequested(Int)
    case taskDeleteRequested(Int)
    case taskTitleChanged(Int, String)
    case categorySelectionToggled
    case scrollOffsetChanged(CGFloat, Bool)
    case floatingButtonTapped
}

// MARK: - State (UI 상태)
public struct CalendarState: Equatable {
    var selectedDate = Date()
    var selectedToggle: CalendarNavigationBar.ToggleOption = .week
    var dailySchedules: [DailySchedule] = []
    var todoItems: [DesignSystem.TodoItem] = []
    
    var showDatePicker = false
    var showTaskEditSheet = false
    var showCategorySelection = false
    var scrollOffset: CGFloat = 0
    var isScrolling = false
    
    var selectedTaskIndex: Int?
    var editingTaskIndex: Int?
    
    var isLoading = false
    var errorMessage: String?
    
    // Computed Properties
    var isFloatingButtonExpanded: Bool {
        scrollOffset == 0 && !isScrolling
    }
    
    var currentDateString: String {
        selectedDate.toString(format: "yyyy년 M월")
    }
    
    public static func == (lhs: CalendarState, rhs: CalendarState) -> Bool {
        lhs.selectedDate == rhs.selectedDate &&
        lhs.selectedToggle == rhs.selectedToggle &&
        lhs.dailySchedules.count == rhs.dailySchedules.count &&
        lhs.todoItems.count == rhs.todoItems.count &&
        lhs.showDatePicker == rhs.showDatePicker &&
        lhs.showTaskEditSheet == rhs.showTaskEditSheet &&
        lhs.showCategorySelection == rhs.showCategorySelection &&
        lhs.isLoading == rhs.isLoading
    }
}

// MARK: - Effect (부수 효과)
public enum CalendarEffect {
    case navigateToTaskCreate(Date)
    case navigateToTaskEdit(Int, String, String?, String?, Date)
    case showError(String)
}

// MARK: - Store (MVI 컨테이너)
public final class CalendarStore: ObservableObject {
    @Dependency private var calendarUseCase: CalendarUseCaseProtocol
    
    @Published public private(set) var state = CalendarState()
    private let effectSubject = PassthroughSubject<CalendarEffect, Never>()
    
    public var effect: AnyPublisher<CalendarEffect, Never> {
        effectSubject.eraseToAnyPublisher()
    }
    
    public init() {}
    
    // MARK: - Intent Handler
    public func send(_ intent: CalendarIntent) {
        Task { @MainActor in
            await handle(intent)
        }
    }
    
    // MARK: - State Mutation (Internal use only)
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
            
        case .datePicker(let isPresented, let previousDate):
            handleDatePicker(isPresented: isPresented, previousDate: previousDate)
            
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
            
        case .floatingButtonTapped:
            handleFloatingButtonTapped()
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
    func handleDatePicker(isPresented: Bool, previousDate: Date?) {
        state.showDatePicker = isPresented
        
        if !isPresented, let previous = previousDate,
           !Calendar.current.isDate(state.selectedDate, equalTo: previous, toGranularity: .month) {
            Task { @MainActor in
                await loadSchedules()
                updateTodoItemsForSelectedDate()
            }
        }
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
        // TODO: API 호출
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
    
    @MainActor
    func handleFloatingButtonTapped() {
        if state.showCategorySelection {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                state.showCategorySelection = false
            }
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                state.showCategorySelection = true
            }
        }
    }
}

// MARK: - Business Logic
private extension CalendarStore {
    @MainActor
    func loadSchedules() async {
        state.isLoading = true
        state.errorMessage = nil
        
        do {
            let schedules = try await fetchSchedules()
            state.dailySchedules = schedules
            state.isLoading = false
            updateTodoItemsForSelectedDate()
        } catch {
            state.errorMessage = "일정을 불러오는데 실패했습니다: \(error.localizedDescription)"
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
    
    func createTodoFromCategory(
        id: Int,
        title: String,
        category: TaskCategory,
        time: String? = nil
    ) -> DesignSystem.TodoItem {
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
            let daySchedule = getDaySchedule(for: date)
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
    
    private func getDaySchedule(for date: Date) -> DailySchedule? {
        let dateString = date.toString(format: "yyyy-MM-dd")
        return state.dailySchedules.first { $0.date == dateString }
    }
    
    private func getSchedulesForDate(_ date: Date) -> [Schedule] {
        return getDaySchedule(for: date)?.schedules ?? []
    }
    
    private func temperatureImage(_ temperature: Int) -> Image {
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
