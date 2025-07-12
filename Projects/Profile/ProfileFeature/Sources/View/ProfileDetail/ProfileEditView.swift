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
    @ObservedObject private var store: ProfileStore
    
    @State private var cancellables = Set<AnyCancellable>()
    
    public init() {
        self.store = DIContainer.shared.resolve(ProfileStore.self)
    }
    
    // 테스트용 생성자
    public init(store: ProfileStore) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar.conditionalBack(
                title: "계정 설정",
                showBackButton: true,
                onBackTapped: {
                    coordinator.pop()
                }
            )
            .padding(.bottom, 48)
            
            if store.state.isLoading {
                loadingView
            } else {
                profileEditForm
            }
            
            Spacer()
            
            saveButton
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            print("📱 ProfileEditView 화면 표시")
            setupEffectSubscription()
            store.loadInitialData()
        }
        .onDisappear {
            print("👋 ProfileEditView 화면 종료")
        }
        .alert("오류", isPresented: .constant(store.state.generalError != nil)) {
            Button("확인") {
                store.clearErrors()
            }
        } message: {
            if let error = store.state.generalError {
                Text(error)
            }
        }
    }
    
    // MARK: - Views
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("프로필 정보를 불러오는 중...")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.top, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var profileEditForm: some View {
        NWUserInputView(
            title: "정보를 작성해 주세요",
            subtitle: "언제든 변경할 수 있어요"
        ) {
            VStack(spacing: 24) {
                NWNicknameInputSection(
                    nickname: Binding(
                        get: {
                            print("🔍 닉네임 상태 조회: \(store.state.nickname)")
                            return store.state.nickname
                        },
                        set: { newValue in
                            print("✏️ 닉네임 업데이트: \(newValue)")
                            store.updateNickname(newValue)
                        }
                    ),
                    nicknameError: store.state.nicknameError
                )
                
                NWBirthDateInputSection(
                    birthDate: Binding(
                        get: {
                            print("🔍 생년월일 상태 조회: \(store.state.birthDate)")
                            return store.state.birthDate
                        },
                        set: { newValue in
                            print("📅 생년월일 업데이트: \(newValue)")
                            store.updateBirthDate(newValue)
                        }
                    ),
                    birthDateError: store.state.birthDateError
                )
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)
        }
    }
    
    private var saveButton: some View {
        NWButton(
            title: store.state.isSaving ? "저장 중..." : "저장",
            variant: .black,
            isEnabled: store.state.isFormValid
        ) {
            print("💾 저장 버튼 클릭")
            store.saveProfile()
        }
    }
    
    // MARK: - Effect Subscription
    
    private func setupEffectSubscription() {
        print("🔗 Effect 구독 설정")
        
        store.effect
            .receive(on: DispatchQueue.main)
            .sink { effect in
                handleEffect(effect)
            }
            .store(in: &cancellables)
    }
    
    private func handleEffect(_ effect: ProfileEditEffect) {
        print("⚡ Effect 수신: \(effect)")
        
        switch effect {
        case .showSuccessMessage(let message):
            print("✅ Success: \(message)")
            // TODO: 실제 앱에서는 토스트 메시지 표시
            
        case .showErrorMessage(let message):
            print("❌ Error: \(message)")
            // TODO: 실제 앱에서는 에러 토스트 메시지 표시
            
        case .navigateBack:
            print("🔙 뒤로가기 네비게이션")
            coordinator.pop()
        }
    }
}
