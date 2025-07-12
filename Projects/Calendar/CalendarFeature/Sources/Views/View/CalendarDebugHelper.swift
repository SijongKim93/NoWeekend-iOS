//
//  esfsef.swift
//  CalendarFeature
//
//  Created by 이지훈 on 7/12/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//


//
//  CalendarDebugHelper.swift
//  CalendarFeature
//
//  Created by Assistant on 7/12/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation
import CalendarDomain
import Utils

// MARK: - Debug Helper for Calendar Data Mapping
extension CalendarStore {
    
    /// 디버그용: API 데이터와 캘린더 매핑 상태 확인
    func debugCalendarMapping() {
        print("🔍 === 캘린더 데이터 매핑 디버그 ===")
        print("📅 선택된 날짜: \(state.selectedDate.toString(format: "yyyy-MM-dd"))")
        print("📊 받은 일정 데이터 개수: \(state.dailySchedules.count)")
        
        for daySchedule in state.dailySchedules {
            print("📋 \(daySchedule.date): 일정 \(daySchedule.schedules.count)개")
            for (index, schedule) in daySchedule.schedules.enumerated() {
                print("  [\(index + 1)] \(schedule.title) - 온도: \(schedule.temperature)°C")
            }
        }
        
        // 현재 주간 범위 확인
        let (startDate, endDate) = calculateWeekRange(for: state.selectedDate)
        print("🗓️ 주간 범위: \(startDate.toString()) ~ \(endDate.toString())")
        
        // 각 날짜별 매핑 확인
        var currentDate = startDate
        while currentDate <= endDate {
            let schedulesCount = getSchedulesForDate(currentDate).count
            let hasData = schedulesCount > 0 ? "✅" : "❌"
            print("\(hasData) \(currentDate.toString()): \(schedulesCount)개 일정")
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        print("===========================================")
    }
    
    /// 특정 날짜의 매핑 정보 확인
    func debugDateMapping(for date: Date) {
        let dateString = date.toString(format: "yyyy-MM-dd")
        let schedules = getSchedulesForDate(date)
        
        print("🎯 날짜별 매핑 확인: \(dateString)")
        print("   - 찾은 일정: \(schedules.count)개")
        
        if schedules.isEmpty {
            print("   - ❌ 해당 날짜에 일정 없음")
            
            // 비슷한 날짜 확인
            let similarDates = state.dailySchedules.filter { 
                abs($0.date.compare(dateString)) < 2
            }
            
            if !similarDates.isEmpty {
                print("   - 📊 비슷한 날짜들:")
                for similar in similarDates {
                    print("     \(similar.date): \(similar.schedules.count)개")
                }
            }
        } else {
            let avgTemp = calculateAverageTemperature(for: schedules)
            print("   - ✅ 평균 온도: \(avgTemp)°C")
            print("   - 🖼️ 매핑될 이미지: \(getImageName(for: avgTemp))")
            
            for schedule in schedules {
                print("     • \(schedule.title) (\(schedule.temperature)°C)")
            }
        }
    }
    
    private func getImageName(for temperature: Int) -> String {
        switch temperature {
        case 0...20: return "imgToastNone"
        case 21...40: return "imgToastDefault"
        case 41...60: return "imgToastEven"
        case 61...80: return "imgToastBurn"
        case 81...100: return "imgToastVacation"
        default: return "imgFlour"
        }
    }
}

private extension String {
    func compare(_ other: String) -> Int {
        return self.compare(other).rawValue
    }
}