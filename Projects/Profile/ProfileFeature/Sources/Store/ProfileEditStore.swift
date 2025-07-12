//
//  ProfileEditStore.swift
//  ProfileFeature
//
//  Created by 김시종 on 7/12/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Combine
import Foundation
import ProfileDomain

public final class ProfileEditStore: ObservableObject {
    
    @Published public private(set) var state = ProfileEditState()
    
    private let effectSubject = PassthroughSubject<ProfileEditEffect, Never>()
    public var effect: AnyPublisher<ProfileEditEffect, Never> {
        effectSubject.eraseToAnyPublisher()
    }
    
    private let updateUserProfileUseCase: UpdateUserProfileUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    public init(updateUserProfileUseCase: UpdateUserProfileUseCaseProtocol) {
        self.updateUserProfileUseCase = updateUserProfileUseCase
    }
    
    public func send(_ action: ProfileEditAction) {
        switch action {
        case .initializeWithProfile(let profile):
            handleInitializeWithProfile(profile)
            
        case .updateNickname(let nickname):
            handleUpdateNickname(nickname)
            
        case .updateBirthDate(let birthDate):
            handleUpdateBirthDate(birthDate)
            
        case .saveProfile:
            handleSaveProfile()
            
        case .profileSaved(let profile):
            handleProfileSaved(profile)
            
        case .profileSaveFailed(let error):
            handleProfileSaveFailed(error)
            
        case .clearErrors:
            handleClearErrors()
            
        case .resetState:
            handleResetState()
        }
    }
    
    // MARK: - Action Handlers (편집 로직만)
    
    private func handleInitializeWithProfile(_ profile: UserProfile) {
        state.nickname = profile.nickname ?? profile.name
        state.birthDate = formatBirthDateForDisplay(profile.birthDate)
        
        // UI 검증만 수행 (길이, 빈 값 등)
        validateNicknameUI(state.nickname)
        validateBirthDateUI(state.birthDate)
    }
    
    private func handleUpdateNickname(_ nickname: String) {
        let filteredNickname = String(nickname.prefix(7))
        state.nickname = filteredNickname
        validateNicknameUI(filteredNickname)
    }
    
    private func handleUpdateBirthDate(_ birthDate: String) {
        let filteredBirthDate = birthDate.filter { $0.isNumber }
        let limitedBirthDate = String(filteredBirthDate.prefix(8))
        state.birthDate = limitedBirthDate
        validateBirthDateUI(limitedBirthDate)
    }
    
    private func handleSaveProfile() {
        guard state.isFormValid else { return }
        
        state.isSaving = true
        state.generalError = nil
        
        let request = UserProfileUpdateRequest(
            nickname: state.nickname,
            birthDate: formatBirthDateForAPI(state.birthDate)
        )
        
        Task { @MainActor in
            do {
                let updatedProfile = try await updateUserProfileUseCase.execute(request)
                send(.profileSaved(updatedProfile))
            } catch {
                send(.profileSaveFailed(error))
            }
        }
    }
    
    private func handleProfileSaved(_ profile: UserProfile) {
        state.isSaving = false
        state.saveSuccess = true
        effectSubject.send(.showSuccessMessage("프로필이 성공적으로 저장되었습니다"))
        effectSubject.send(.navigateBack)
    }
    
    private func handleProfileSaveFailed(_ error: Error) {
        state.isSaving = false
        
        if let validationError = error as? ProfileValidationError {
            switch validationError {
            case .emptyNickname, .nicknameTooLong:
                state.nicknameError = validationError.localizedDescription
            case .invalidBirthDate:
                state.birthDateError = validationError.localizedDescription
            default:
                state.generalError = validationError.localizedDescription
            }
        } else {
            state.generalError = error.localizedDescription
        }
        
        effectSubject.send(.showErrorMessage("프로필 저장에 실패했습니다"))
    }
    
    private func handleClearErrors() {
        state.nicknameError = nil
        state.birthDateError = nil
        state.generalError = nil
    }
    
    private func handleResetState() {
        state = ProfileEditState()
    }
    
    // MARK: - UI 검증 (간단한 것만)
    
    private func validateNicknameUI(_ nickname: String) {
        if nickname.isEmpty {
            state.nicknameError = "닉네임을 입력해주세요"
        } else if nickname.count > 6 {
            state.nicknameError = "닉네임은 6글자 이하로 입력해주세요"
        } else {
            state.nicknameError = nil
        }
    }
    
    private func validateBirthDateUI(_ birthDate: String) {
        if birthDate.isEmpty {
            state.birthDateError = "생년월일을 입력해주세요"
        } else if birthDate.count != 8 {
            state.birthDateError = "생년월일 8자리를 모두 입력해주세요"
        } else {
            state.birthDateError = nil
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatBirthDateForDisplay(_ birthDate: String?) -> String {
        guard let birthDate = birthDate else { return "" }
        let cleaned = birthDate.replacingOccurrences(of: "-", with: "")
        return cleaned
    }
    
    private func formatBirthDateForAPI(_ birthDate: String) -> String {
        birthDate
    }
    
    func initializeWith(profile: UserProfile) {
        send(.initializeWithProfile(profile))
    }
    
    func updateNickname(_ nickname: String) {
        send(.updateNickname(nickname))
    }
    
    func updateBirthDate(_ birthDate: String) {
        send(.updateBirthDate(birthDate))
    }
    
    func saveProfile() {
        send(.saveProfile)
    }
    
    func clearErrors() {
        send(.clearErrors)
    }
    
    func resetState() {
        send(.resetState)
    }
}
