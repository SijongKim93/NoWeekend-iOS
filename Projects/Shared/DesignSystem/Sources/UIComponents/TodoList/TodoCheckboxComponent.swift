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
    
    public init(id: Int, title: String, isCompleted: Bool, category: TodoCategory?, time: String?) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.category = category
        self.time = time
    }
}

public struct TodoCheckboxComponent: View {
    public let todoItem: TodoItem
    public let onToggle: () -> Void
    public let onMoreTapped: (() -> Void)?
    public let onTitleChanged: ((String) -> Void)?
    public let isEditingMode: Bool
    
    @State private var isEditing: Bool = false
    @State private var editingTitle: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    public init(
        todoItem: TodoItem,
        onToggle: @escaping () -> Void,
        onMoreTapped: (() -> Void)? = nil,
        onTitleChanged: ((String) -> Void)? = nil,
        isEditingMode: Bool = false
    ) {
        self.todoItem = todoItem
        self.onToggle = onToggle
        self.onMoreTapped = onMoreTapped
        self.onTitleChanged = onTitleChanged
        self.isEditingMode = isEditingMode
    }
    
    public init(
        isCompleted: Bool,
        title: String,
        category: TodoCategory? = TodoCategory(name: "개인", color: DS.Colors.TaskItem.orange),
        time: String? = nil,
        onToggle: @escaping () -> Void,
        onMoreTapped: (() -> Void)? = nil,
        onTitleChanged: ((String) -> Void)? = nil,
        isEditingMode: Bool = false
    ) {
        self.todoItem = TodoItem(
            id: 0,
            title: title,
            isCompleted: isCompleted,
            category: category,
            time: time
        )
        self.onToggle = onToggle
        self.onMoreTapped = onMoreTapped
        self.onTitleChanged = onTitleChanged
        self.isEditingMode = isEditingMode
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
                titleSection
                
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
        }
        .padding(.vertical, 12)
        .padding(.leading, 24)
        .padding(.trailing, 16)
        .opacity(todoItem.isCompleted ? 0.32 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: todoItem.isCompleted)
        .onTapGesture {
            if onTitleChanged != nil && !isEditing {
                startEditing()
            }
        }
        .onChange(of: isEditingMode) { _, newValue in
            if newValue && onTitleChanged != nil {
                startEditing()
            }
        }
    }
}

// MARK: - 편집 기능
private extension TodoCheckboxComponent {
    @ViewBuilder
    var titleSection: some View {
        if isEditing {
            TextField("할 일을 입력하세요", text: $editingTitle)
                .font(.body2)
                .foregroundColor(DS.Colors.Neutral.gray900)
                .focused($isTextFieldFocused)
                .onSubmit {
                    finishEditing()
                }
        } else {
            Text(todoItem.title)
                .font(.body2)
                .foregroundColor(DS.Colors.Neutral.gray900)
                .lineLimit(1)
        }
    }
    
    func startEditing() {
        editingTitle = todoItem.title
        isEditing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isTextFieldFocused = true
        }
    }
    
    func finishEditing() {
        let trimmedTitle = editingTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !trimmedTitle.isEmpty && trimmedTitle != todoItem.title {
            onTitleChanged?(trimmedTitle)
        }
        
        isEditing = false
        isTextFieldFocused = false
    }
}

#Preview {
    VStack(spacing: 16) {
        TodoCheckboxComponent(
            isCompleted: false,
            title: "기본 개인 할일",
            onToggle: { },
            onTitleChanged: { newTitle in
                print("제목 변경: \(newTitle)")
            }
        )
        
        TodoCheckboxComponent(
            isCompleted: false,
            title: "편집 모드 할일",
            onToggle: { },
            onTitleChanged: { newTitle in
                print("제목 변경: \(newTitle)")
            },
            isEditingMode: true
        )
    }
    .background(Color.gray.opacity(0.1))
}
