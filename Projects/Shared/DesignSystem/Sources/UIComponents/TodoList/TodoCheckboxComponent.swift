//
//  TodoCheckboxComponent.swift
//  Shared
//
//  Created by 이지훈 on 6/22/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI

public struct TodoCategory {
    public let name: String
    public let color: Color
    
    public init(name: String, color: Color) {
        self.name = name
        self.color = color
    }
}

public struct TodoItem: Identifiable {
    public let id: Int
    public var title: String
    public var isCompleted: Bool
    public let category: TodoCategory?
    public let time: String?
    public let scheduleId: String?
    
    public init(id: Int, title: String, isCompleted: Bool, category: TodoCategory?, time: String?, scheduleId: String? = nil) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.category = category
        self.time = time
        self.scheduleId = scheduleId
    }
}

public struct TodoCheckboxComponent: View {
    public let todoItem: TodoItem
    public let onToggle: () -> Void
    public let onMoreTapped: (() -> Void)?
    
    public init(
        todoItem: TodoItem,
        onToggle: @escaping () -> Void,
        onMoreTapped: (() -> Void)? = nil
    ) {
        self.todoItem = todoItem
        self.onToggle = onToggle
        self.onMoreTapped = onMoreTapped
    }
    
    public init(
        isCompleted: Bool,
        title: String,
        category: TodoCategory? = TodoCategory(name: "개인", color: DS.Colors.TaskItem.orange),
        time: String? = nil,
        onToggle: @escaping () -> Void,
        onMoreTapped: (() -> Void)? = nil
    ) {
        self.todoItem = TodoItem(
            id: 0,
            title: title,
            isCompleted: isCompleted,
            category: category,
            time: time,
            scheduleId: nil
        )
        self.onToggle = onToggle
        self.onMoreTapped = onMoreTapped
    }
    
    private var timeOrDate: String {
        if let time = todoItem.time {
            return time
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M월 d일"
            return formatter.string(from: Date())
        }
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                (todoItem.isCompleted ? DS.Images.icnCheckbox : DS.Images.icTodo)
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(todoItem.title)
                    .font(.body2)
                    .foregroundColor(DS.Colors.Neutral.gray900)
                    .lineLimit(1)
                
                if todoItem.category != nil {
                    HStack(spacing: 8) {
                        if let category = todoItem.category {
                            Text(category.name)
                                .font(.body3)
                                .foregroundColor(category.color)
                        }
                        
                        if todoItem.category != nil && todoItem.time != nil {
                            Rectangle()
                                .fill(DS.Colors.Border.border02)
                                .frame(width: 2, height: 12)
                        }
                        
                        Text(timeOrDate)
                            .font(.body2)
                            .foregroundColor(DS.Colors.Text.body)
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                onMoreTapped?()
            }) {
                DS.Images.icnThreeDots
                    .resizable()
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 12)
        .padding(.leading, 24)
        .padding(.trailing, 16)
        .opacity(todoItem.isCompleted ? 0.32 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: todoItem.isCompleted)
    }
}

#Preview {
    VStack(spacing: 16) {
        TodoCheckboxComponent(
            isCompleted: false,
            title: "기본 개인 할일",
            onToggle: { print("체크박스 클릭") },
            onMoreTapped: { print("더보기 클릭") }
        )
        
        TodoCheckboxComponent(
            isCompleted: true,
            title: "완료된 할일",
            category: TodoCategory(name: "연차", color: DS.Colors.TaskItem.purple),
            onToggle: { print("체크박스 클릭") },
            onMoreTapped: { print("더보기 클릭") }
        )
    }
    .background(Color.gray.opacity(0.1))
}
