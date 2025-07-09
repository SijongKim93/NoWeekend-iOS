//
//  CalendarRepositoryProtocol.swift
//  CalendarDomain
//
//  Created by 이지훈 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public protocol CalendarRepositoryProtocol {
    func getSchedules(startDate: String, endDate: String) async throws -> [DailySchedule]
<<<<<<< HEAD
    func createSchedule(request: CreateScheduleRequest) async throws -> Schedule
    func updateSchedule(id: String, request: UpdateScheduleRequest) async throws -> Schedule  
    func deleteSchedule(id: String) async throws
=======
    func deleteSchedule(id: String) async throws -> String
>>>>>>> 7a5f5bf (feat/#62 일정삭제 레포지토리 구현)
}
