//
//  ProfileStore.swift
//  ProfileFeature
//
//  Created by SiJongKim on 7/11/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation
import Combine
import ProfileDomain

public final class ProfileStore: ObservableObject {
    
    @Published public private(set) var state = ProfileState()
    
    private let effectSubject = PassthroughSubject<ProfileEditEffect, Never>()
    public var effect: AnyPublisher<ProfileEditEffect, Never> {
        effectSubject.eraseToAnyPublisher()
    }
    
    private let getUserProfileUseCase: GetUserProfileUseCaseProtocol
    private let updateUserProfileUseCase: UpdateUserProfileUseCaseProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        getUserProfileUseCase: GetUserProfileUseCaseProtocol,
        updateUserProfileUseCase: UpdateUserProfileUseCaseProtocol
    ) {
        self.getUserProfileUseCase = getUserProfileUseCase
        self.updateUserProfileUseCase = updateUserProfileUseCase
    }
    
    public func send(_ action: ProfileEditAction) {
        switch action {
        case .loadUserProfile:
            handleLoadUserProfile()
            
        case .userProfileLoaded(let profile):
            handleUserProfileLoaded(profile)
            
        case .loadUserProfileFailed(let error):
            handleLoadUserProfileFailed(error)
            
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
    
    // MARK: - Action Handlers
    
    private func handleLoadUserProfile() {
        state.isLoading = true
        state.generalError = nil
        
        Task { @MainActor in
            do {
                let profile = try await getUserProfileUseCase.execute()
                send(.userProfileLoaded(profile))
            } catch {
                send(.loadUserProfileFailed(error))
            }
        }
    }
    
    private func handleUserProfileLoaded(_ profile: UserProfile) {
        state.isLoading = false
        state.userProfile = profile
        
        // 프로필 데이터로 폼 초기화
        state.nickname = profile.nickname ?? profile.name
        state.birthDate = formatBirthDateForDisplay(profile.birthDate)
        
        // 초기 유효성 검사
        validateNickname(state.nickname)
        validateBirthDate(state.birthDate)
    }
    
    private func handleLoadUserProfileFailed(_ error: Error) {
        state.isLoading = false
        state.generalError = error.localizedDescription
        
        effectSubject.send(.showErrorMessage("프로필 정보를 불러오는데 실패했습니다"))
    }
    
    private func handleUpdateNickname(_ nickname: String) {
        let filteredNickname = String(nickname.prefix(7)) // 최대 7글자 제한
        state.nickname = filteredNickname
        validateNickname(filteredNickname)
    }
    
    private func handleUpdateBirthDate(_ birthDate: String) {
        let filteredBirthDate = birthDate.filter { $0.isNumber }
        let limitedBirthDate = String(filteredBirthDate.prefix(8)) // YYYYMMDD 8자리 제한
        state.birthDate = limitedBirthDate
        validateBirthDate(limitedBirthDate)
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
        state.userProfile = profile
        
        effectSubject.send(.showSuccessMessage("프로필이 성공적으로 저장되었습니다"))
        
        // 1초 후 자동으로 뒤로가기
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.effectSubject.send(.navigateBack)
        }
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
        state = ProfileState()
    }
    
    // MARK: - Validation Methods
    
    private func validateNickname(_ nickname: String) {
        if nickname.isEmpty {
            state.nicknameError = "닉네임을 입력해주세요"
        } else if nickname.count > 6 {
            state.nicknameError = "닉네임은 6글자 이하로 입력해주세요"
        } else {
            state.nicknameError = nil
        }
    }
    
    private func validateBirthDate(_ birthDate: String) {
        if birthDate.isEmpty {
            state.birthDateError = "생년월일을 입력해주세요"
        } else if birthDate.count != 8 {
            state.birthDateError = "생년월일 8자리를 모두 입력해주세요"
        } else if !isValidBirthDateFormat(birthDate) {
            state.birthDateError = "올바른 생년월일을 입력해주세요"
        } else {
            state.birthDateError = nil
        }
    }
    
    private func isValidBirthDateFormat(_ birthDate: String) -> Bool {
        guard birthDate.count == 8,
              birthDate.allSatisfy({ $0.isNumber }) else {
            return false
        }
        
        let yearString = String(birthDate.prefix(4))
        let monthString = String(birthDate.dropFirst(4).prefix(2))
        let dayString = String(birthDate.suffix(2))
        
        guard let year = Int(yearString),
              let month = Int(monthString),
              let day = Int(dayString) else {
            return false
        }
        
        // 기본 범위 검증
        guard year >= 1900 && year <= 2024,
              month >= 1 && month <= 12,
              day >= 1 && day <= 31 else {
            return false
        }
        
        return true
    }
    
    // MARK: - Helper Methods
    
    private func formatBirthDateForDisplay(_ birthDate: String?) -> String {
        guard let birthDate = birthDate else { return "" }
        
        // "1999-12-13" -> "19991213" 형태로 변환
        let cleaned = birthDate.replacingOccurrences(of: "-", with: "")
        return cleaned
    }
    
    private func formatBirthDateForAPI(_ birthDate: String) -> String {
        // 이미 "19991213" 형태이므로 그대로 반환
        return birthDate
    }
}

// MARK: - Convenience Methods

public extension ProfileStore {
    
    func loadInitialData() {
        send(.loadUserProfile)
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
