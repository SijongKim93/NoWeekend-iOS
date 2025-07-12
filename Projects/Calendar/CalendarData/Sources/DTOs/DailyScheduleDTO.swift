//
//  DailyScheduleDTO.swift
//  CalendarData
//
//  Created by 이지훈 on 7/8/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import CalendarDomain
import Foundation

public struct DailyScheduleDTO: Decodable {
    public let date: String
    public let schedules: [ScheduleDTO]
}

extension DailyScheduleDTO {
    public func toDomain() -> DailySchedule {
        DailySchedule(
            date: date,
            schedules: schedules.map { $0.toDomain() }
        )
    }
}
