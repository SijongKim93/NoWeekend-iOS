//
//  HolidayDTO.swift
//  HomeData
//
//  Created by 김나희 on 7/13/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation
import HomeDomain

public struct HolidayResponseDTO: Codable {
    public let result: String
    public let data: HolidayDataDTO?
    public let error: String?
    
    public init(result: String, data: HolidayDataDTO?, error: String?) {
        self.result = result
        self.data = data
        self.error = error
    }
}

public struct HolidayDataDTO: Codable {
    public let holidays: [HolidayItemDTO]
    
    public init(holidays: [HolidayItemDTO]) {
        self.holidays = holidays
    }
}

public struct HolidayItemDTO: Codable {
    public let date: String
    public let content: String
    public let dayOfWeekKor: String
    
    public init(date: String, content: String, dayOfWeekKor: String) {
        self.date = date
        self.content = content
        self.dayOfWeekKor = dayOfWeekKor
    }
    
    public func toDomain() -> Holiday? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormatter.date(from: date) else {
            return nil
        }
        
        return Holiday(date: date, name: content, dayOfWeekKor: dayOfWeekKor)
    }
} 