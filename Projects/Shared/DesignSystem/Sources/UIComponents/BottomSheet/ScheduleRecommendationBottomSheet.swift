//
//  ScheduleRecommendationBottomSheet.swift
//  DesignSystem
//
//  Created by Assistant on 7/14/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI

public struct ScheduleRecommendationBottomSheet: View {
    @Binding var isPresented: Bool
    let onScheduleSelected: (RecommendedSchedule) -> Void
    let onAddSchedule: () -> Void
    
    @State private var selectedSchedule: RecommendedSchedule?
    
    private let recommendedSchedules = [
        RecommendedSchedule(title: "김나희", category: .general),
        RecommendedSchedule(title: "카리나", category: .work),
        RecommendedSchedule(title: "@@@카리나희레츠고!!!", category: .personal)
    ]
    
    public init(
        isPresented: Binding<Bool>,
        onScheduleSelected: @escaping (RecommendedSchedule) -> Void,
        onAddSchedule: @escaping () -> Void
    ) {
        self._isPresented = isPresented
        self.onScheduleSelected = onScheduleSelected
        self.onAddSchedule = onAddSchedule
    }
    
    public var body: some View {
        BottomSheetContainer(height: 266) {
            VStack(spacing: 0) {
                Text("딱 맞는 일정을 추천했어요.")
                    .font(.heading4)
                    .foregroundColor(DS.Colors.Text.netural)
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(recommendedSchedules.enumerated()), id: \.offset) { index, schedule in
                            NWTagButton(
                                title: schedule.title,
                                isSelected: selectedSchedule?.id == schedule.id,
                                style: .outlined,
                                size: .medium,
                                fillsAvailableWidth: false
                            ) {
                                selectedSchedule = schedule
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                    .frame(height: 40)
                
                Button(action: {
                    if let selected = selectedSchedule {
                        onScheduleSelected(selected)
                    } else {
                        onAddSchedule()
                    }
                    isPresented = false
                }) {
                    Text("추가하기")
                        .font(.heading6)
                        .fontWeight(.medium)
                        .foregroundColor(DS.Colors.Neutral.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(DS.Colors.Neutral.black)
                        )
                }
            }
        }
    }
}

// MARK: - Supporting Types
public struct RecommendedSchedule: Identifiable {
    public let id = UUID()
    public let title: String
    public let category: ScheduleRecommendationCategory
    
    public init(title: String, category: ScheduleRecommendationCategory) {
        self.title = title
        self.category = category
    }
}

public enum ScheduleRecommendationCategory {
    case general
    case work
    case personal
    
    var color: Color {
        switch self {
        case .general: return DS.Colors.TaskItem.etc
        case .work: return DS.Colors.TaskItem.green
        case .personal: return DS.Colors.TaskItem.orange
        }
    }
}

#Preview {
    VStack {
        Spacer()
        Text("메인 화면")
        Spacer()
    }
    .sheet(isPresented: .constant(true)) {
        ScheduleRecommendationBottomSheet(
            isPresented: .constant(true),
            onScheduleSelected: { schedule in
                print("선택된 일정: \(schedule.title)")
            },
            onAddSchedule: {
                print("새 일정 추가")
            }
        )
    }
}
