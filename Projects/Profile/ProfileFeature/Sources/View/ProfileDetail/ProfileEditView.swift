//
//  ProfileEditView.swift (DIContainer 연동)
//  ProfileFeature
//
//  Created by SiJongKim on 7/4/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI
import DesignSystem
import DIContainer
import Combine

public struct ProfileEditView: View {
    @EnvironmentObject private var coordinator: ProfileCoordinator
    @ObservedObject private var profileStore: ProfileStore
    @ObservedObject private var editStore: ProfileEditStore
    
    @State private var cancellables = Set<AnyCancellable>()
    
    public init() {
        self.profileStore = DIContainer.shared.resolve(ProfileStore.self)
        self.editStore = DIContainer.shared.resolve(ProfileEditStore.self)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                type: .backWithLabelAndSave("계정 설정"),
                onBackTapped: {
                    coordinator.pop()
                },
                onSaveTapped: {
                    editStore.saveProfile()
                }
            )
            .padding(.bottom, 48)
            
            profileEditForm
            
            Spacer()
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            setupEffectSubscription()
            loadProfileData()
        }
        .alert("오류", isPresented: .constant(editStore.state.generalError != nil)) {
            Button("확인") {
                editStore.clearErrors()
            }
        } message: {
            if let error = editStore.state.generalError {
                Text(error)
            }
        }
    }
    
    private var profileEditForm: some View {
        NWUserInputView(
            title: "정보를 작성해 주세요",
            subtitle: "언제든 변경할 수 있어요"
        ) {
            VStack(spacing: 24) {
                NWNicknameInputSection(
                    nickname: Binding(
                        get: { editStore.state.nickname },
                        set: { editStore.updateNickname($0) }
                    ),
                    nicknameError: editStore.state.nicknameError
                )
                
                NWBirthDateInputSection(
                    birthDate: Binding(
                        get: { editStore.state.birthDate },
                        set: { editStore.updateBirthDate($0) }
                    ),
                    birthDateError: editStore.state.birthDateError
                )
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadProfileData() {
        if let profile = profileStore.state.userProfile {
            editStore.initializeWith(profile: profile)
        } else {
            profileStore.loadInitialData()
        }
    }
    
    private func setupEffectSubscription() {
        // Profile Store Effect 구독
        profileStore.effect
            .receive(on: DispatchQueue.main)
            .sink { effect in
                switch effect {
                case .showErrorMessage(let message):
                    print("❌ Profile Error: \(message)")
                }
            }
            .store(in: &cancellables)
        
        // Profile Store 상태 변화 감지
        profileStore.$state
            .map(\.userProfile)
            .compactMap { $0 }
            .removeDuplicates()
            .sink { profile in
                editStore.initializeWith(profile: profile)
            }
            .store(in: &cancellables)
        
        // Edit Store Effect 구독
        editStore.effect
            .receive(on: DispatchQueue.main)
            .sink { effect in
                handleEditEffect(effect)
            }
            .store(in: &cancellables)
    }
    
    private func handleEditEffect(_ effect: ProfileEditEffect) {
        switch effect {
        case .showSuccessMessage(let message):
            print("✅ Success: \(message)")
            
        case .showErrorMessage(let message):
            print("❌ Error: \(message)")
            
        case .navigateBack:
            coordinator.pop()
        }
    }
}
