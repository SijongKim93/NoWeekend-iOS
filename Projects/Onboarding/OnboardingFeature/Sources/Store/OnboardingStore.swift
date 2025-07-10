//
//  OnboardingStore.swift (수정된 버전)
//  Onboarding
//
//  Created by SiJongKim on 6/23/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI
import Combine
import OnboardingDomain

public class OnboardingStore: ObservableObject {
    
    // MARK: - Published State
    @Published public var state = OnboardingState()
    
    // MARK: - Dependencies
    private let reducer = OnboardingReducer()
    private let intentMapper = OnboardingIntentMapper()
    
    private let saveProfileUseCase: SaveProfileUseCaseInterface
    private let saveLeaveUseCase: SaveLeaveUseCaseInterface
    private let saveTagsUseCase: SaveTagsUseCaseInterface
    private let validateNicknameUseCase: ValidateNicknameUseCaseInterface
    private let validateBirthDateUseCase: ValidateBirthDateUseCaseInterface
    private let validateRemainingDaysUseCase: ValidateRemainingDaysUseCaseInterface
    
    // MARK: - Initialization
    public init(
        saveProfileUseCase: SaveProfileUseCaseInterface,
        saveLeaveUseCase: SaveLeaveUseCaseInterface,
        saveTagsUseCase: SaveTagsUseCaseInterface,
        validateNicknameUseCase: ValidateNicknameUseCaseInterface,
        validateBirthDateUseCase: ValidateBirthDateUseCaseInterface,
        validateRemainingDaysUseCase: ValidateRemainingDaysUseCaseInterface
    ) {
        self.saveProfileUseCase = saveProfileUseCase
        self.saveLeaveUseCase = saveLeaveUseCase
        self.saveTagsUseCase = saveTagsUseCase
        self.validateNicknameUseCase = validateNicknameUseCase
        self.validateBirthDateUseCase = validateBirthDateUseCase
        self.validateRemainingDaysUseCase = validateRemainingDaysUseCase
        
        DispatchQueue.main.async {
            self.send(.validateCurrentStep)
        }
    }
    
    // MARK: - Intent Processing
    public func send(_ intent: OnboardingIntent) {
        performImmediateValidation(for: intent)
        
        let actions = intentMapper.mapIntent(intent, currentState: state)
        
        for action in actions {
            processAction(action)
        }
        
        performAdditionalValidation(for: intent)
    }
    
    // MARK: - 즉시 유효성 검사
    private func performImmediateValidation(for intent: OnboardingIntent) {
        switch intent {
        case .updateNickname(let nickname):
            let filteredNickname = String(nickname.prefix(7))
            let result = validateNicknameUseCase.execute(filteredNickname)
            
            DispatchQueue.main.async {
                self.state.nickname = filteredNickname
                self.state.nicknameError = result.errorMessage
                self.updateStepValidation()
            }
            
        case .updateBirthDate(let birthDate):
            let filteredBirthDate = String(birthDate.filter { $0.isNumber }.prefix(8))
            let result = validateBirthDateUseCase.execute(filteredBirthDate)
            
            DispatchQueue.main.async {
                self.state.birthDate = filteredBirthDate
                self.state.birthDateError = result.errorMessage
                self.updateStepValidation()
            }
            
        case .updateRemainingDays(let days):
            let filteredDays = String(days.filter { $0.isNumber }.prefix(2))
            let result = validateRemainingDaysUseCase.execute(filteredDays)
            
            DispatchQueue.main.async {
                self.state.remainingDays = filteredDays
                self.state.remainingDaysError = result.errorMessage
                self.updateStepValidation()
            }
            
        default:
            break
        }
    }
    
    // MARK: - 스텝 유효성 즉시 업데이트
    private func updateStepValidation() {
        state.isNextButtonEnabled = state.isCurrentStepValid && !state.isLoading
    }
    
    // MARK: - Action Processing
    private func processAction(_ action: OnboardingAction) {
        DispatchQueue.main.async {
            self.state = self.reducer.reduce(self.state, action)
        }
        
        handleSideEffects(for: action)
    }
    
    // MARK: - Side Effects
    private func handleSideEffects(for action: OnboardingAction) {
        switch action {
        case .saveProfileStarted:
            Task { @MainActor in
                do {
                    try await saveProfileUseCase.execute(
                        nickname: state.nickname,
                        birthDate: state.birthDate
                    )
                    processAction(.saveProfileSucceeded)
                } catch {
                    processAction(.saveProfileFailed(error))
                }
            }
            
        case .saveLeaveStarted:
            Task { @MainActor in
                do {
                    let days = Int(state.remainingDays) ?? 0
                    let hours = Int(state.remainingHours) ?? 0
                    
                    try await saveLeaveUseCase.execute(days: days, hours: hours)
                    processAction(.saveLeaveSucceeded)
                } catch {
                    processAction(.saveLeaveSuccaFailed(error))
                }
            }
            
        case .saveTagsStarted:
            Task { @MainActor in
                do {
                    let tags = Array(state.selectedTags)
                    try await saveTagsUseCase.execute(tags: tags)
                    processAction(.saveTagsSucceeded)
                } catch {
                    processAction(.saveTagsFailed(error))
                }
            }
            
            // 모든 저장이 완료되었을 때 온보딩 완료 처리
        case .saveTagsSucceeded:
            print("✅ OnboardingStore: 모든 온보딩 데이터 저장 완료")
            DispatchQueue.main.async {
                self.state.isOnboardingCompleted = true
            }
            
        default:
            break
        }
    }
    
    // MARK: - Additional Validation (토글, 태그 등에만 사용)
    private func performAdditionalValidation(for intent: OnboardingIntent) {
        switch intent {
        case .updateHasHalfDay(_), .toggleTag(_):
            DispatchQueue.main.async {
                self.updateStepValidation()
            }
            
        case .validateCurrentStep:
            DispatchQueue.main.async {
                self.updateStepValidation()
            }
            
        default:
            break
        }
    }
}
