//
//  OnboardingStore.swift (Reducer 중심으로 수정된 버전)
//  Onboarding
//
//  Created by SiJongKim on 6/23/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI
import Combine
import OnboardingDomain

@MainActor
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
        
        Task {
            await send(.validateCurrentStep)
        }
    }
    
    // MARK: - Intent Processing
    public func send(_ intent: OnboardingIntent) {
        let validationActions = createValidationActions(for: intent)
        
        let mappedActions = intentMapper.mapIntent(intent, currentState: state)
        
        let allActions = validationActions + mappedActions
        
        for action in allActions {
            processAction(action)
        }
    }
    
    // MARK: - 유효성 검사를 통한 Action 생성
    private func createValidationActions(for intent: OnboardingIntent) -> [OnboardingAction] {
        switch intent {
        case .updateNickname(let nickname):
            let filteredNickname = String(nickname.prefix(7))
            let result = validateNicknameUseCase.execute(filteredNickname)
            
            return [
                .nicknameUpdated(filteredNickname, errorMessage: result.errorMessage),
                .stepValidationRequested
            ]
            
        case .updateBirthDate(let birthDate):
            let filteredBirthDate = String(birthDate.filter { $0.isNumber }.prefix(8))
            let result = validateBirthDateUseCase.execute(filteredBirthDate)
            
            return [
                .birthDateUpdated(filteredBirthDate, errorMessage: result.errorMessage),
                .stepValidationRequested
            ]
            
        case .updateRemainingDays(let days):
            let filteredDays = String(days.filter { $0.isNumber }.prefix(2))
            let result = validateRemainingDaysUseCase.execute(filteredDays)
            
            return [
                .remainingDaysUpdated(filteredDays, errorMessage: result.errorMessage),
                .stepValidationRequested
            ]
            
        case .updateHasHalfDay(_), .toggleTag(_):
            return [.stepValidationRequested]
            
        case .validateCurrentStep:
            return [.stepValidationRequested]
            
        default:
            return []
        }
    }
    
    // MARK: - Action Processing (단일 진실의 원천)
    private func processAction(_ action: OnboardingAction) {
        state = reducer.reduce(state, action)
        
        handleSideEffects(for: action)
    }
    
    // MARK: - Side Effects
    private func handleSideEffects(for action: OnboardingAction) {
        switch action {
        case .saveProfileStarted:
            Task {
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
            Task {
                do {
                    let days = Int(state.remainingDays) ?? 0
                    let hours = Int(state.remainingHours) ?? 0
                    
                    try await saveLeaveUseCase.execute(days: days, hours: hours)
                    processAction(.saveLeaveSucceeded)
                } catch {
                    processAction(.saveLeaveFailed(error))
                }
            }
            
        case .saveTagsStarted:
            Task {
                do {
                    let tags = Array(state.selectedTags)
                    try await saveTagsUseCase.execute(tags: tags)
                    processAction(.saveTagsSucceeded)
                } catch {
                    processAction(.saveTagsFailed(error))
                }
            }
            
        case .saveTagsSucceeded:
            print("✅ OnboardingStore: 모든 온보딩 데이터 저장 완료")
            processAction(.onboardingCompleted)
            
        default:
            break
        }
    }
}
