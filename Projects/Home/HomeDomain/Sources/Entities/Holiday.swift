//
//  Holiday.swift
//  HomeDomain
//
//  Created by 김나희 on 7/13/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public struct Holiday: Equatable {
    public let date: Date
    public let name: String
    public let dayOfWeekKor: String
    
    public init(date: Date, name: String, dayOfWeekKor: String) {
        self.date = date
        self.name = name
        self.dayOfWeekKor = dayOfWeekKor
    }
}

public extension Holiday {
    var dateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M/dd"
        let datePart = formatter.string(from: date)
        let weekKor = dayOfWeekKorKor
        return "\(datePart)(\(weekKor))"
    }
    
    var dayOfWeekKorKor: String {
        switch dayOfWeekKor.uppercased() {
        case "MON": return "월"
        case "TUE": return "화"
        case "WED": return "수"
        case "THU": return "목"
        case "FRI": return "금"
        case "SAT": return "토"
        case "SUN": return "일"
        default: return dayOfWeekKor
        }
    }
} 
