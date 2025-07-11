//
//  ProfileEditView.swift
//  Mypage
//
//  Created by SiJongKim on 7/4/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI
import DesignSystem

struct ProfileEditView: View {
    @EnvironmentObject private var coordinator: ProfileCoordinator
    
    @State private var nickname: String = ""
    @State private var birthDate: String = ""
    @State private var nicknameError: String? = nil
    @State private var birthDateError: String? = nil
    
    @State private var isLoading: Bool = false
    @State private var showSaveSuccess: Bool = false
    
    let onLoad: () -> (nickname: String, birthDate: String)
    let onSave: (String, String) -> Void
    
    init(
        onLoad: @escaping () -> (nickname: String, birthDate: String),
        onSave: @escaping (String, String) -> Void
    ) {
        self.onLoad = onLoad
        self.onSave = onSave
    }
    
    var body: some View {
        VStack {
            CustomNavigationBar.conditionalBack(
                title: "계정 설정",
                showBackButton: true,
                onBackTapped: {
                    coordinator.pop()
                }
            )
            .padding(.bottom, 48)
            
            NWUserInputView(
                title: "정보를 작성해 주세요."
            ) {
                VStack(spacing: 24) {
                    NWNicknameInputSection(
                        nickname: Binding(
                            get: { nickname },
                            set: { newValue in
                                let filteredValue = String(newValue.prefix(7))
                                nickname = filteredValue
                                validateNickname(filteredValue)
                            }
                        ),
                        nicknameError: nicknameError
                    )
                    
                    NWBirthDateInputSection(
                        birthDate: Binding(
                            get: { store.state.birthDate },
                            set: { newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                store.send(.updateBirthDate(filtered))
                            }
                        ),
                        birthDateError: store.state.birthDateError
                    )
                }
            }
            .padding(.bottom, 48)
        }
    }
    
    private func validateNickname(_ value: String) {
        if value.isEmpty {
            nicknameError = "닉네임을 입력해주세요"
        } else if value.count > 6 {
            nicknameError = "닉네임은 6글자 이하로 입력해주세요"
        } else {
            nicknameError = nil
        }
    }
}
