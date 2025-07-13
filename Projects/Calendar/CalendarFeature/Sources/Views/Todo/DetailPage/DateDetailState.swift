//
//  DateDetailState.swift
//  CalendarFeature
//
//  Created by 이지훈 on 7/13/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import CalendarDomain
import DesignSystem

public struct DateDetailState {
    var schedules: [Schedule] = []
    var todoItems: [DesignSystem.TodoItem] = []
    var isLoading = false
    var errorMessage: String?
    var selectedTaskIndex: Int?
    var showTaskEditSheet = false
    var editingTaskIndex: Int?
    var showCategorySelection = false
    
    var averageTemperature: Int {
        guard !schedules.isEmpty else { return 50 }
        let totalTemperature = schedules.reduce(0) { $0 + $1.temperature }
        return totalTemperature / schedules.count
    }
    
    var incompleteTodoCount: Int {
        todoItems.filter { !$0.isCompleted }.count
    }
}
