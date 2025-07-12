//
//  CalendarModels.swift
//  CalendarFeature
//
//  Created by Assistant on 7/12/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation
import CalendarDomain
import DesignSystem
import SwiftUI
import Utils

// MARK: - Domain Extensions
extension DailySchedule {
    /// 해당 날짜의 평균 온도 계산
    var dailyTemperature: Int {
        guard !schedules.isEmpty else { return 0 }
        let totalTemperature = schedules.reduce(0) { $0 + $1.temperature }
        return totalTemperature / schedules.count
    }
}

extension ScheduleCategory {
    /// DesignSystem 컬러 매핑
    var designSystemColor: Color {
        switch self {
        case .company: return DS.Colors.TaskItem.green
        case .personal: return DS.Colors.TaskItem.orange
        case .leave: return DS.Colors.TaskItem.purple
        case .etc: return DS.Colors.TaskItem.etc
        }
    }
}

