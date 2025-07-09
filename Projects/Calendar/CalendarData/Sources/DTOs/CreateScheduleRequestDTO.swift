//
//  CreateScheduleDTO.swift
//  CalendarData
//
//  Created by Assistant on 7/9/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation
import CalendarDomain

public struct CreateScheduleRequestDTO: Codable {
    public let title: String
    public let date: String
    public let startTime: String
    public let endTime: String
    public let category: String
    public let temperature: Int
    public let allDay: Bool
    public let alarmOption: String
}

public struct CreateScheduleResponseDTO: Codable {
    public let id: String
    public let title: String
    public let startTime: String
    public let endTime: String
    public let category: String
    public let temperature: Int
    public let allDay: Bool
    public let alarmOption: String
    public let completed: Bool
}

extension CreateScheduleResponseDTO {
    public func toDomain() -> Schedule {
        let dateFormatter = ISO8601DateFormatter()
        
        return Schedule(
            id: id,
            title: title,
            startTime: dateFormatter.date(from: startTime) ?? Date(),
            endTime: dateFormatter.date(from: endTime) ?? Date(),
            category: ScheduleCategory(rawValue: category) ?? .other,
            temperature: temperature,
            allDay: allDay,
            alarmOption: AlarmOption(rawValue: alarmOption) ?? .none,
            completed: completed
        )
    }
}
