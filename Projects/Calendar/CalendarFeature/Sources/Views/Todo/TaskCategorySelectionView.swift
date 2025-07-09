//
//  TaskCategorySelectionView.swift
//  CalendarFeature
//
//  Created by Assistant on 7/9/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import DesignSystem
import SwiftUI

public struct TaskCategorySelectionView: View {
    @Binding var isPresented: Bool
    let onCategorySelected: (TaskCategory) -> Void
    
    @State private var opacity: Double = 0
    @State private var scale: Double = 0.8
    
    private let categories: [TaskCategory] = [
        TaskCategory(name: "출근하기", color: DS.Colors.TaskItem.green),
        TaskCategory(name: "운동하기", color: DS.Colors.TaskItem.orange),
        TaskCategory(name: "선물사기", color: DS.Colors.Neutral.gray700)
    ]
    
    public init(
        isPresented: Binding<Bool>,
        onCategorySelected: @escaping (TaskCategory) -> Void
    ) {
        self._isPresented = isPresented
        self.onCategorySelected = onCategorySelected
    }
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.5 * opacity)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissWithAnimation()
                }
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            ForEach(Array(categories.enumerated()), id: \.offset) { index, category in
                                CategoryRowCenter(
                                    category: category
                                ) {
                                    selectCategory(category)
                                }
                            }
                        }
                        
                        Rectangle()
                            .fill(DS.Colors.Border.border01)
                            .frame(height: 1)
                        
                        Button(action: {
                            dismissWithAnimation()
                        }) {
                            HStack {
                                Text("직접 입력")
                                    .font(.body1)
                                    .foregroundColor(DS.Colors.Text.netural)
                                
                                Spacer()
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 20)
                            .contentShape(Rectangle())
                        }
                    }
                    .frame(width: 200)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                    )
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .padding(.trailing, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .onAppear {
            presentWithAnimation()
        }
    }
    
    private func presentWithAnimation() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            opacity = 1
            scale = 1
        }
    }
    
    private func dismissWithAnimation() {
        withAnimation(.easeInOut(duration: 0.25)) {
            opacity = 0
            scale = 0.8
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isPresented = false
        }
    }
    
    private func selectCategory(_ category: TaskCategory) {
        onCategorySelected(category)
        dismissWithAnimation()
    }
}

struct CategoryRowCenter: View {
    let category: TaskCategory
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Circle()
                    .fill(category.color)
                    .frame(width: 8, height: 8)
                
                Text(category.name)
                    .font(.body1)
                    .foregroundColor(DS.Colors.Text.netural)
                
                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    TaskCategorySelectionView(
        isPresented: .constant(true),
        onCategorySelected: { category in
            print("선택된 카테고리: \(category.name)")
        }
    )
}
