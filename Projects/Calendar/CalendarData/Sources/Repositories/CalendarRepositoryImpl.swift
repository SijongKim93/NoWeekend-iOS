//
//  CalendarRepositoryImpl.swift
//  CalendarData
//
//  Created by 이지훈 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation
import CalendarDomain
import Foundation
import NWNetwork
import Utils

public enum NetworkError: Error {
    case serverError(String)
    case networkError(String)
    case unknown
}

public final class CalendarRepositoryImpl: CalendarRepositoryProtocol {
    private let networkService: NWNetworkServiceProtocol
    
    public init(networkService: NWNetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    public func getSchedules(startDate: String, endDate: String) async throws -> [DailySchedule] {
        let parameters = [
            "start_date": startDate,
            "end_date": endDate
        ]
        
        let response: ScheduleResponseDTO = try await networkService.get(
            endpoint: "/schedule",
            parameters: parameters
        )
        
        guard response.result == "SUCCESS" else {
            let errorMessage = response.error?.message ?? "API 실패"
            throw NetworkError.serverError(errorMessage)
        }
        
        return response.data.map { $0.toDomain() }
    }
    
    public func createSchedule(request: CreateScheduleRequest) async throws -> Schedule {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let isoFormatter = ISO8601DateFormatter()
        
        let requestDTO = CreateScheduleRequestDTO(
            title: request.title,
            date: dateFormatter.string(from: request.date),
            startTime: isoFormatter.string(from: request.startTime),
            endTime: isoFormatter.string(from: request.endTime),
            category: request.category.rawValue,
            temperature: request.temperature,
            allDay: request.allDay,
            alarmOption: request.alarmOption.rawValue
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(requestDTO)
        let parameters = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        let response: CreateScheduleResponseDTO = try await networkService.post(
            endpoint: "/schedule",
            parameters: parameters
        )
        
        return response.toDomain()
    }
    
    public func updateSchedule(id: String, request: UpdateScheduleRequest) async throws -> Schedule {
        let isoFormatter = ISO8601DateFormatter()
        
        let requestDTO = UpdateScheduleRequestDTO(
            title: request.title,
            startTime: isoFormatter.string(from: request.startTime),
            endTime: isoFormatter.string(from: request.endTime),
            category: request.category.rawValue,
            temperature: request.temperature,
            allDay: request.allDay,
            alarmOption: request.alarmOption.rawValue
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(requestDTO)
        let parameters = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        let response: UpdateScheduleAPIResponseDTO = try await networkService.put(
            endpoint: "/schedule/\(id)",
            parameters: parameters
        )
        
        guard response.result == "SUCCESS", let data = response.data else {
            let errorMessage = response.error?.message ?? "일정 수정 실패"
            throw NetworkError.serverError(errorMessage)
        }
        
        return data.toDomain()
    }
    
    public func deleteSchedule(id: String) async throws {
        let response: ScheduleResponseDTO = try await networkService.delete(
            endpoint: "/schedule/\(id)"
        )
        
        guard response.result == "SUCCESS" else {
        }
            throw NetworkError.serverError(errorMessage)
            let errorMessage = response.error?.message ?? "일정 삭제 실패"
            throw NetworkError.serverError(errorMessage)
        }
        
        return response.data ?? "일정이 성공적으로 삭제되었습니다."
    }
}
