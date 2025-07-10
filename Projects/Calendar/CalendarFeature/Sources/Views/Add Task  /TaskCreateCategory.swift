//
//  TaskCreateCategory.swift
//  CalendarFeature
//
//  Created by 이지훈 on 7/10/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import DesignSystem
import SwiftUI

public enum TaskCreateCategory: String, CaseIterable, Hashable {
    case company = "company"
    case personal = "personal"
    case other = "other"
    case vacation = "vacation"
    
    public var displayName: String {
        switch self {
        case .company: return "회사"
        case .personal: return "개인"
        case .other: return "기타"
        case .vacation: return "연차"
        }
    }
    
    public var color: Color {
        switch self {
        case .company: return DS.Colors.TaskItem.green
        case .personal: return DS.Colors.TaskItem.orange
        case .other: return DS.Colors.TaskItem.etc
        case .vacation: return DS.Colors.TaskItem.purple
        }
    }
}
