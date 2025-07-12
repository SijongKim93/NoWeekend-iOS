//
//  UpdateScheduleRequest.swift
//  CalendarDomain
//
//  Created by 이지훈 on 7/9/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public struct UpdateScheduleRequest {
    public let title: String
    public let startTime: Date
    public let endTime: Date
    public let category: ScheduleCategory
    public let temperature: Int
    public let allDay: Bool
    public let alarmOption: AlarmOption
    
    public init(
        title: String,
        startTime: Date,
        endTime: Date,
        category: ScheduleCategory,
        temperature: Int,
        allDay: Bool,
        alarmOption: AlarmOption
    ) {
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.category = category
        self.temperature = temperature
        self.allDay = allDay
        self.alarmOption = alarmOption
    }
}
