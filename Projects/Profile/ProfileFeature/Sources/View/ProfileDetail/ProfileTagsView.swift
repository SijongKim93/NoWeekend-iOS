//
//  ProfileTagsView.swift
//  ProfileFeature
//
//  Created by SiJongKim on 7/11/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Combine
import DesignSystem
import DIContainer
import SwiftUI

struct ProfileTagsView: View {
    @EnvironmentObject var coordinator: ProfileCoordinator
    @ObservedObject private var tagsStore: TagsStore
    
    @State private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.tagsStore = DIContainer.shared.resolve(TagsStore.self)
    }
    
    init(tagsStore: TagsStore) {
        self.tagsStore = tagsStore
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                type: .backWithLabelAndSave("자주하는 일정"),
                onBackTapped: {
                    coordinator.pop()
                },
                onSaveTapped: {
                    handleSaveButtonTapped()
                }
            )
            .padding(.bottom, 48)
            
            VStack {
                NWUserInputView(
                    title: "자주하는 일정을 알려주세요",
                    subtitle: "할일 등록을 AI에게 추천받을 수 있어요"
                ) {
                    VStack {
                        createTagSelectionView()
                    }
                    .padding(.top, 40)
                }
                
                Spacer()
                
//                NWButton(
//                    title: buttonTitle,
//                    variant: .black,
//                    isEnabled: tagsStore.state.isFormValid && !tagsStore.state.isSaving
//                ) {
//                    handleSaveButtonTapped()
//                }
//                .padding(.horizontal, 24)
//                .padding(.bottom, 8)
            }
        }
        .background(DS.Colors.Background.normal)
        .navigationBarHidden(true)
        .onAppear {
            setupView()
        }
        .onReceive(tagsStore.effect) { effect in
            handleEffect(effect)
        }
    }
    
    private func setupView() {
        tagsStore.loadInitialData()
    }
    
    private func createTagSelectionView() -> some View {
           let defaultTags = [
               ["출근", "퇴근", "회의 참석", "점심 식사 약속"],
               ["헬스장 운동", "카페에서 작업/휴식", "친구 만남"],
               ["술자리", "스터디", "학원 수업", "야근"],
               ["추가 업무", "산책", "반려동물 산책", "집안일"],
               ["은행 업무", "관공서 업무", "독서", "데이트"],
               ["미용실", "드라이브", "나들이", "넷플릭스 시청"],
               ["유튜브 시청", "치지직 시청"]
           ]
           
           return NWTagSelectionView.custom(
               tags: defaultTags,
               selectedTags: Set(tagsStore.allSelectedTags),
               minSelectionCount: 3,
               onTagToggle: { tag in
                   if tagsStore.availableBasicTags.contains(tag) {
                       tagsStore.toggleBasicTag(tag)
                   } else {
                       tagsStore.toggleCustomTag(tag)
                   }
               }
           )
    }
    
    private var buttonTitle: String {
        if tagsStore.state.isSaving {
            return "저장 중..."
        } else if tagsStore.state.isFormValid {
            return "저장하기"
        } else {
            return "3개 이상 선택해주세요"
        }
    }
    
    private func handleSaveButtonTapped() {
        guard tagsStore.state.isFormValid && !tagsStore.state.isSaving else { return }
        tagsStore.saveTags()
    }
    
    private func handleEffect(_ effect: TagsEffect) {
        switch effect {
        case .navigateBack:
            coordinator.pop()
            
        case .showSuccessMessage(let message):
            // 성공 메시지 표시 로직
            print("✅ \(message)")
            
        case .showErrorMessage(let message):
            // 에러 메시지 표시 로직
            print("❌ \(message)")
        case .showTagAddDialog:
            print("showTagAddDialog")
        }
    }
}

#Preview {
    ProfileTagsView()
}
