//
//  TodoScrollSection.swift
//  Feature
//
//  Created by 이지훈 on 6/28/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import DesignSystem
import SwiftUI

struct TodoScrollSection: View {
    @Binding var todoItems: [DesignSystem.TodoItem]
    @Binding var selectedTaskIndex: Int?
    @Binding var showTaskEditSheet: Bool
    @Binding var scrollOffset: CGFloat
    @Binding var isScrolling: Bool
    @Binding var editingTaskIndex: Int?
    
    var onTitleChanged: ((Int, String) -> Void)?
    
    private var incompleteTodoCount: Int {
        todoItems.filter { !$0.isCompleted }.count
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 1)
                    .onAppear {
                        scrollOffset = 0
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if scrollOffset == 0 {
                                isScrolling = false
                            }
                        }
                    }
                    .onDisappear {
                        scrollOffset = 100
                    }
                
                todoSection
            }
        }
        .onAppear {
            scrollOffset = 0
            isScrolling = false
        }
        .gesture(
            DragGesture()
                .onChanged { _ in
                    if !isScrolling {
                        isScrolling = true
                    }
                }
                .onEnded { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        isScrolling = false
                    }
                }
        )
    }
    
    private var todoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 0) {
                    Text("할 일 ")
                        .font(.heading5)
                        .foregroundStyle(DS.Colors.Text.netural)
                    
                    Text("\(incompleteTodoCount)")
                        .font(.heading5)
                        .foregroundStyle(DS.Colors.Text.netural)
                    
                    Text(" / ")
                        .font(.heading5)
                        .foregroundStyle(DS.Colors.Text.disable)
                    
                    Text("\(todoItems.count)")
                        .font(.heading5)
                        .foregroundStyle(DS.Colors.Text.disable)
                    
                    Text("개")
                        .font(.heading5)
                        .foregroundStyle(DS.Colors.Text.netural)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            LazyVStack(spacing: 0) {
                ForEach(Array(todoItems.enumerated()), id: \.element.id) { index, todo in
                    TodoCheckboxComponent(
                        todoItem: todo,
                        onToggle: {
                            todoItems[index].isCompleted.toggle()
                        },
                        onMoreTapped: {
                            selectedTaskIndex = index
                            showTaskEditSheet = true
                        }
                    )
                    .contentShape(Rectangle())
                }
            }
        }
    }
}
