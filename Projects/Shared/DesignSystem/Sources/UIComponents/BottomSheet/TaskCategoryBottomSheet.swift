//
//  TaskCategoryBottomSheet.swift
//  Shared
//
//  Created by 이지훈 on 7/14/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI

public struct TaskCategoryBottomSheet: View {
    @Binding public var selectedCategory: TaskCreateCategory
    public let onCategorySelected: (TaskCreateCategory) -> Void
    public let onSelectTapped: () -> Void
    @Binding public var isPresented: Bool
    
    private let categories: [TaskCreateCategory] = [.company, .personal, .other, .vacation]
    
    public init(
        selectedCategory: Binding<TaskCreateCategory>,
        onCategorySelected: @escaping (TaskCreateCategory) -> Void,
        onSelectTapped: @escaping () -> Void,
        isPresented: Binding<Bool>
    ) {
        self._selectedCategory = selectedCategory
        self.onCategorySelected = onCategorySelected
        self.onSelectTapped = onSelectTapped
        self._isPresented = isPresented
    }
    
    public var body: some View {
        BottomSheetContainer(height: 280) {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("새 할 일을 추가할 때")
                        .font(.heading4)
                        .foregroundColor(DS.Colors.Text.netural)
                        .multilineTextAlignment(.center)
                    
                    Text("사용할 기본 카테고리를 선택하세요.")
                        .font(.heading4)
                        .foregroundColor(DS.Colors.Text.netural)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)
                
                categorySelectionSection
                
                selectButton
            }
        }
    }
    
    private var categorySelectionSection: some View {
        VStack(spacing: 0) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 12)
                    .fill(DS.Colors.Background.alternative01)
                    .frame(height: 48)
                
                // Sliding indicator
                GeometryReader { geometry in
                    let segmentWidth = geometry.size.width / CGFloat(categories.count)
                    let selectedIndex = categories.firstIndex(of: selectedCategory) ?? 0
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .stroke(selectedCategory.color, lineWidth: 2)
                        .frame(width: segmentWidth - 4, height: 40)
                        .offset(x: CGFloat(selectedIndex) * segmentWidth + 2, y: 4)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedCategory)
                }
                .frame(height: 48)
                
                // Category buttons
                HStack(spacing: 0) {
                    ForEach(categories, id: \.self) { category in
                        CategorySegmentButton(
                            category: category,
                            isSelected: selectedCategory == category,
                            onTap: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    selectedCategory = category
                                    onCategorySelected(category)
                                }
                            }
                        )
                    }
                }
            }
            .frame(height: 48)
        }
    }
    
    private var selectButton: some View {
        Button(action: {
            onSelectTapped()
            isPresented = false
        }) {
            Text("선택하기")
                .font(.heading6)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(DS.Colors.Neutral.black)
                )
        }
    }
}


public struct CategorySegmentButton: View {
    let category: TaskCreateCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    public var body: some View {
        Button(action: onTap) {
            Text(category.displayName)
                .font(.body1)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundColor(isSelected ? category.color : DS.Colors.Text.netural)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .contentShape(Rectangle())
        }
    }
}

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

public enum VacationType: String, CaseIterable {
    case halfDay = "half_day"
    case fullDay = "full_day"
    case morningHalf = "morning_half"
    case afternoonHalf = "afternoon_half"
    
    public var displayName: String {
        switch self {
        case .halfDay: return "반차"
        case .fullDay: return "하루 종일"
        case .morningHalf: return "오전 반차"
        case .afternoonHalf: return "오후 반차"
        }
    }
}

// MARK: - Preview

#Preview {
    @State var isPresented = true
    @State var selectedCategory: TaskCreateCategory = .personal
    
    return TaskCategoryBottomSheet(
        selectedCategory: $selectedCategory,
        onCategorySelected: { category in
            print("카테고리 선택됨: \(category.displayName)")
        },
        onSelectTapped: {
            print("선택하기 버튼 탭됨")
        },
        isPresented: $isPresented
    )
}
