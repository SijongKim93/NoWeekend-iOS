//
//  ProfileEditView.swift
//  Mypage
//
//  Created by SiJongKim on 7/4/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI
import DesignSystem

public struct ProfileEditView: View {
    @State private var nickname: String = ""
    @State private var birthDate: String = ""
    @State private var nicknameError: String? = nil
    @State private var birthDateError: String? = nil
    
    // 저장 상태
    @State private var isLoading: Bool = false
    @State private var showSaveSuccess: Bool = false
    
    // 초기값 로드를 위한 클로저
    public let onLoad: () -> (nickname: String, birthDate: String)
    public let onSave: (String, String) -> Void
    
    public init(
        onLoad: @escaping () -> (nickname: String, birthDate: String),
        onSave: @escaping (String, String) -> Void
    ) {
        self.onLoad = onLoad
        self.onSave = onSave
    }
    
    public var body: some View {
        VStack {
            CustomNavigationBar.conditionalBack(
                title: "계정 설정",
                showBackButton: true,
                onBackTapped: {
                    
                }
            )
            
            NWUserInputView(
                title: "정보를 작성해 주세요."
            ) {
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
            }
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
