//
//  DateDetailStore.swift
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

@MainActor
@Observable
public class DateDetailStore {
    public var state = DateDetailState()
    
    let selectedDate: Date
    private let calendarUseCase: CalendarUseCaseProtocol?
    
    public init(selectedDate: Date, calendarUseCase: CalendarUseCaseProtocol? = nil) {
        self.selectedDate = selectedDate
        self.calendarUseCase = calendarUseCase
    }
    
    public func send(_ intent: DateDetailIntent) {
        switch intent {
        case .loadSchedules:
            Task { await loadSchedules() }
            
        case .toggleTask(let index):
            guard index < state.todoItems.count else { return }
            state.todoItems[index].isCompleted.toggle()
            
        case .showTaskEditSheet(let index):
            state.selectedTaskIndex = index
            state.showTaskEditSheet = true
            
        case .hideTaskEditSheet:
            state.showTaskEditSheet = false
            
        case .editTask:
            state.showTaskEditSheet = false
            if let index = state.selectedTaskIndex {
                state.editingTaskIndex = index
            }
            
        case .tomorrowTask:
            state.showTaskEditSheet = false
            
        case .deleteTask:
            state.showTaskEditSheet = false
            if let index = state.selectedTaskIndex {
                state.todoItems.remove(at: index)
                state.selectedTaskIndex = nil
            }
            
        case .showCategorySelection:
            state.showCategorySelection = true
            
        case .hideCategorySelection:
            state.showCategorySelection = false
            
        case .selectCategory(let category):
            let newTodo = DesignSystem.TodoItem(
                id: state.todoItems.count + 1,
                title: category.name,
                isCompleted: false,
                category: DesignSystem.TodoCategory(name: category.name, color: category.color),
                time: nil
            )
            state.todoItems.append(newTodo)
            state.editingTaskIndex = state.todoItems.count - 1
            state.showCategorySelection = false
            
        case .navigateToTaskCreate:
            state.showCategorySelection = false
        }
    }
}

// MARK: - Private Methods
private extension DateDetailStore {
    func loadSchedules() async {
        guard let useCase = calendarUseCase ?? DIContainer.shared.container.resolve(CalendarUseCaseProtocol.self) else {
            await loadMockData()
            return
        }
        
        state.isLoading = true
        state.errorMessage = nil
        
        do {
            let dateString = selectedDate.toString(format: "yyyy-MM-dd")
            let dailySchedules = try await useCase.getSchedulesForDateRange(
                startDate: selectedDate,
                endDate: selectedDate
            )
            
            if let daySchedule = dailySchedules.first(where: { $0.date == dateString }) {
                let schedulesForDay = daySchedule.schedules
                state.schedules = schedulesForDay
                state.todoItems = createTodoItemsFromSchedules(schedulesForDay)
            } else {
                state.schedules = []
                state.todoItems = []
            }
            state.isLoading = false
            
        } catch {
            state.errorMessage = error.localizedDescription
            state.isLoading = false
        }
    }
    
    func loadMockData() async {
        state.schedules = mockSchedules
        state.todoItems = mockTodoItems
        state.isLoading = false
    }
    
    var mockSchedules: [Schedule] {
        [
            Schedule(
                id: "1",
                title: "길게 들어가면 이렇게 보여집니다. 길게 들어...",
                startTime: Date(),
                endTime: Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date(),
                category: .company,
                temperature: 50,
                allDay: false,
                alarmOption: .none,
                completed: false
            ),
            Schedule(
                id: "2",
                title: "할 일 제목이 들어갑니다.",
                startTime: Date(),
                endTime: Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date(),
                category: .personal,
                temperature: 60,
                allDay: false,
                alarmOption: .none,
                completed: true
            )
        ]
    }
    
    var mockTodoItems: [DesignSystem.TodoItem] {
        [
            DesignSystem.TodoItem(
                id: 1,
                title: "길게 들어가면 이렇게 보여집니다. 길게 들어...",
                isCompleted: false,
                category: DesignSystem.TodoCategory(name: "회사", color: DS.Colors.TaskItem.green),
                time: "오전 10:00"
            ),
            DesignSystem.TodoItem(
                id: 2,
                title: "할 일 제목이 들어갑니다.",
                isCompleted: false,
                category: DesignSystem.TodoCategory(name: "개인", color: DS.Colors.TaskItem.orange),
                time: "오전 10:00"
            ),
            DesignSystem.TodoItem(
                id: 3,
                title: "할 일 제목이 들어갑니다.",
                isCompleted: true,
                category: DesignSystem.TodoCategory(name: "개인", color: DS.Colors.TaskItem.orange),
                time: "오전 10:00"
            )
        ]
    }
    
    func createTodoItemsFromSchedules(_ schedules: [Schedule]) -> [DesignSystem.TodoItem] {
        return schedules.enumerated().map { index, schedule in
            let category = DesignSystem.TodoCategory(
                name: schedule.category.displayName,
                color: schedule.category.designSystemColor
            )
            
            return DesignSystem.TodoItem(
                id: index + 1,
                title: schedule.title,
                isCompleted: schedule.completed,
                category: category,
                time: schedule.allDay ? "하루 종일" : schedule.startTime.toString(format: "a h:mm")
            )
        }
    }
}
