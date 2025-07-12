//
//  TodoItem.swift
//  Feature
//
//  Created by 이지훈 on 6/28/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import DesignSystem
import SwiftUI

struct TodoItem: Identifiable {
    let id: Int
    var title: String
    var isCompleted: Bool
    var category: DesignSystem.TodoCategory?
    var time: String?
    var scheduleId: String?
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

