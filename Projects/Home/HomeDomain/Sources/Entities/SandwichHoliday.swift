//
//  SandwichHoliday.swift
//  HomeDomain
//
//  Created by 김나희 on 7/13/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public struct SandwichHoliday: Equatable, DateStringConvertible {
    public let startDate: Date
    public let endDate: Date
    
    public init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
    }
    
    public var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "M/dd"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        let startString = dateFormatter.string(from: startDate)
        let endString = dateFormatter.string(from: endDate)
        
        return "\(startString) ~ \(endString)"
    }
} 
