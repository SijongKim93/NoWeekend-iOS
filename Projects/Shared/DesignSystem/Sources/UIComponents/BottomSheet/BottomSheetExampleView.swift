//
//  BottomSheetExampleView.swift
//  Shared
//
//  Created by 이지훈 on 6/18/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI

struct BottomSheetExampleView: View {
    @State private var sliderValue: Double = 3.0
    @State private var textInput: String = ""
    @State private var selectedDate: Date = Date()
    @State private var selectedCategory: TaskCreateCategory = .personal
    @State private var selectedTags: Set<String> = ["출근", "헬스장 운동"]
    
    @State private var showSliderSheet = false
    @State private var showTextInputSheet = false
    @State private var showDatePickerWithLabelSheet = false
    @State private var showDatePickerOnlySheet = false
    @State private var showTaskEditSheet = false
    @State private var showDeleteSheet = false
    @State private var showCategorySheet = false
    @State private var showTagSelectionSheet = false
    @State private var showCustomSheet = false
    @State private var showScheduleRecommendationSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("바텀시트 스타일 미리보기")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                VStack(spacing: 16) {
                    Button("슬라이더 바텀시트") {
                        showSliderSheet = true
                    }
                    
                    Button("텍스트 입력 바텀시트") {
                        showTextInputSheet = true
                    }
                    
                    Button("카테고리 선택 바텀시트") {
                        showCategorySheet = true
                    }
                    
                    Button("일정 추천 바텀시트") {
                        showScheduleRecommendationSheet = true
                    }
                    
                    Button("날짜 선택 (레이블 포함) 바텀시트") {
                        showDatePickerWithLabelSheet = true
                    }
                    
                    Button("날짜 선택 (레이블 없음) 바텀시트") {
                        showDatePickerOnlySheet = true
                    }
                    
                    Button("할 일 수정 바텀시트") {
                        showTaskEditSheet = true
                    }
                    
                    Button("삭제 확인 바텀시트") {
                        showDeleteSheet = true
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showSliderSheet) {
            SliderBottomSheet(
                title: "며칠 동안 휴가를 가고 싶나요?",
                value: $sliderValue,
                range: 1...7,
                unit: "일"
            )
        }
        .sheet(isPresented: $showTextInputSheet) {
            TextInputBottomSheet(
                subtitle: "연차 제목을 작성하면\n할 일에 추가돼요",
                placeholder: "연차 제목을 입력하세요",
                text: $textInput,
                isPresented: $showTextInputSheet,
                onAddButtonTapped: {
                    print("할 일 추가됨: \(textInput)")
                    showTextInputSheet = false
                    textInput = ""
                }
            )
        }
        .sheet(isPresented: $showCategorySheet) {
            TaskCategoryBottomSheet(
                selectedCategory: $selectedCategory,
                onCategorySelected: { category in
                    print("카테고리 선택됨: \(category.displayName)")
                },
                onSelectTapped: {
                    print("선택하기 버튼 탭됨")
                },
                isPresented: $showCategorySheet
            )
        }
        .sheet(isPresented: $showScheduleRecommendationSheet) {
            ScheduleRecommendationBottomSheet(
                isPresented: $showScheduleRecommendationSheet,
                onScheduleSelected: { schedule in
                    print("선택된 추천 일정: \(schedule.title)")
                    print("카테고리: \(schedule.category)")
                    showScheduleRecommendationSheet = false
                },
                onAddSchedule: {
                    print("새 일정 추가 버튼 탭됨")
                    showScheduleRecommendationSheet = false
                }
            )
        }
        .sheet(isPresented: $showDatePickerWithLabelSheet) {
            DatePickerWithLabelBottomSheet(selectedDate: $selectedDate)
        }
        .sheet(isPresented: $showDatePickerOnlySheet) {
            BottomSheetContainer(height: 350) {
                DatePickerBottomSheet(selectedDate: $selectedDate)
            }
        }
        .sheet(isPresented: $showTaskEditSheet) {
            TaskEditBottomSheet(
                onEditAction: {
                    print("할일 수정 선택됨")
                },
                onTomorrowAction: {
                    print("내일 또 하기 선택됨")
                },
                onDeleteAction: {
                    print("삭제하기 선택됨")
                    showDeleteSheet = true
                },
                isPresented: $showTaskEditSheet
            )
        }
        .sheet(isPresented: $showDeleteSheet) {
            DeleteBottomSheet(
                message: "정말 삭제하시겠습니까?",
                onDeleteAction: {
                    showDeleteSheet = false
                    print("삭제 완료")
                },
                isPresented: $showDeleteSheet
            )
        }
    }
}

#Preview {
    BottomSheetExampleView()
}
