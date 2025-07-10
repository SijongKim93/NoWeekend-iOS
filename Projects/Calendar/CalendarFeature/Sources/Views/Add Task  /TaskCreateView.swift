//
//  TaskCreateView.swift
//  CalendarFeature
//
//  Created by 이지훈 on 7/9/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import DesignSystem
import SwiftUI

public struct TaskCreateView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategory: TaskCreateCategory = .company
    @State private var title: String = ""
    @State private var titleError: String?
    @State private var showTaskDetail = false
    
    private let categories: [TaskCreateCategory] = [.company, .personal, .other, .vacation]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                navigationBar
                
                ScrollView {
                    VStack(spacing: 32) {
                        categorySection
                        titleSection
                        detailSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }
                
                Spacer()
            }
            .background(DS.Colors.Background.normal)
            .navigationDestination(isPresented: $showTaskDetail) {
                TaskDetailView(selectedCategory: selectedCategory)
            }
        }
    }
    
    private var navigationBar: some View {
        CustomNavigationBar(
            type: .cancelWithLabelAndSave("할 일 추가"),
            onCancelTapped: {
                dismiss()
            },
            onSaveTapped: {
                saveTask()
            }
        )
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(DS.Colors.Background.alternative01)
                    .frame(height: 42)
                
                GeometryReader { geometry in
                    let segmentWidth = geometry.size.width / CGFloat(categories.count)
                    let selectedIndex = categories.firstIndex(of: selectedCategory) ?? 0
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .stroke(selectedCategory.color, lineWidth: 1)
                        .frame(width: segmentWidth - 4, height: 34)
                        .offset(x: CGFloat(selectedIndex) * segmentWidth + 2, y: 4)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedCategory)
                }
                .frame(height: 42)
                
                HStack(spacing: 0) {
                    ForEach(categories, id: \.self) { category in
                        CategorySegmentButton(
                            category: category,
                            isSelected: selectedCategory == category,
                            onTap: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    selectedCategory = category
                                }
                            }
                        )
                    }
                }
            }
            .frame(height: 44)
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading) {
            NWTextField.todoMultiLine(
                text: $title,
                placeholder: "제목",
                errorMessage: $titleError
            )
        }
    }
    
    private var detailSection: some View {
        VStack(spacing: 30) {
            DetailRowButton(
                title: "세부사항",
                onTap: {
                    showTaskDetail = true
                }
            )
        }
    }
    
    private func saveTask() {
        guard !title.isEmpty else {
            titleError = "제목을 입력해주세요"
            return
        }
        
        titleError = nil
        print("할 일 저장: \(title), 카테고리: \(selectedCategory.displayName)")
        dismiss()
    }
}

struct CategorySegmentButton: View {
    let category: TaskCreateCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(category.displayName)
                .font(.body2)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? category.color : DS.Colors.Text.netural)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .contentShape(Rectangle())
        }
    }
}

struct DetailRowButton: View {
    let title: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .font(.body1)
                    .foregroundColor(DS.Colors.Text.netural)
                
                Spacer()
                
                DS.Images.icnChevronRight
                    .foregroundColor(DS.Colors.Neutral.gray500)
            }
            .background(DS.Colors.Background.normal)
        }
    }
}

#Preview {
    TaskCreateView()
}
