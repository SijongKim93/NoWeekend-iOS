//
//  UpdateScheduleRequestDTO.swift
//  CalendarData
//
//  Created by Assistant on 7/9/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation
import CalendarDomain

public struct UpdateScheduleRequestDTO: Codable {
    public let title: String
    public let startTime: String  // ISO8601 형식
    public let endTime: String    // ISO8601 형식
    public let category: String
    public let temperature: Int
    public let allDay: Bool
    public let alarmOption: String
    
    public init(
        title: String,
        startTime: String,
        endTime: String,
        category: String,
        temperature: Int,
        allDay: Bool,
        alarmOption: String
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

public struct UpdateScheduleResponseDTO: Codable {
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

public struct UpdateScheduleAPIResponseDTO: Decodable {
    public let result: String
    public let data: UpdateScheduleResponseDTO?
    public let error: APIError?
}

extension UpdateScheduleResponseDTO {
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
