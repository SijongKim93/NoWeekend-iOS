//
//  VacationStore.swift
//  ProfileFeature
//
//  Created by 김시종 on 7/12/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Combine
import Foundation
import ProfileDomain

public final class VacationStore: ObservableObject {
    
    @Published public private(set) var state = VacationState()
    
    private let effectSubject = PassthroughSubject<VacationEffect, Never>()
    public var effect: AnyPublisher<VacationEffect, Never> {
        effectSubject.eraseToAnyPublisher()
    }
    
    private let updateVacationLeaveUseCase: UpdateVacationLeaveUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    public init(updateVacationLeaveUseCase: UpdateVacationLeaveUseCaseProtocol) {
        self.updateVacationLeaveUseCase = updateVacationLeaveUseCase
    }
    
    public func send(_ action: VacationAction) {
        switch action {
        case .initializeWithProfile(let profile):
            handleInitializeWithProfile(profile)
            
        case .updateRemainingDays(let days):
            handleUpdateRemainingDays(days)
            
        case .updateHasHalfDay(let hasHalf):
            handleUpdateHasHalfDay(hasHalf)
            
        case .saveVacationLeave:
            handleSaveVacationLeave()
            
        case .vacationLeaveSaved(let leave):
            handleVacationLeaveSaved(leave)
            
        case .vacationLeaveSaveFailed(let error):
            handleVacationLeaveSaveFailed(error)
            
        case .clearErrors:
            handleClearErrors()
            
        case .resetState:
            handleResetState()
        }
    }
    
    private func handleInitializeWithProfile(_ profile: UserProfile) {
        let totalHours = Int(profile.remainingAnnualLeave)
        state.remainingDays = totalHours / 8
        state.hasHalfDay = (totalHours % 8) >= 4
        validateRemainingDaysUI(state.remainingDays)
    }
    
    private func handleUpdateRemainingDays(_ days: Int) {
        let validatedDays = max(0, min(50, days))
        state.remainingDays = validatedDays
        validateRemainingDaysUI(validatedDays)
    }
    
    private func handleUpdateHasHalfDay(_ hasHalf: Bool) {
        state.hasHalfDay = hasHalf
    }
    
    private func handleSaveVacationLeave() {
        guard state.isFormValid else { return }
        
        state.isSaving = true
        state.generalError = nil
        
        let totalHours = Int(state.totalRemainingHours)
        let days = totalHours / 8
        let hours = totalHours % 8
        
        let vacationLeave = VacationLeave(days: days, hours: hours)
        
        Task { @MainActor in
            do {
                let savedLeave = try await updateVacationLeaveUseCase.execute(vacationLeave)
                send(.vacationLeaveSaved(savedLeave))
            } catch {
                send(.vacationLeaveSaveFailed(error))
            }
        }
    }
    
    private func handleVacationLeaveSaved(_ leave: VacationLeave) {
        state.isSaving = false
        state.saveSuccess = true
        
        let totalHours = leave.days * 8 + leave.hours
        state.remainingDays = totalHours / 8
        state.hasHalfDay = (totalHours % 8) >= 4
        
        effectSubject.send(.showSuccessMessage("연차 정보가 성공적으로 저장되었습니다"))
        effectSubject.send(.navigateBack)
    }
    
    private func handleVacationLeaveSaveFailed(_ error: Error) {
        state.isSaving = false
        
        if let validationError = error as? ProfileValidationError {
            switch validationError {
            case .invalidVacationDays, .invalidVacationHours, .vacationLeaveTooLong:
                state.remainingDaysError = validationError.localizedDescription
            default:
                state.generalError = validationError.localizedDescription
            }
        } else {
            state.generalError = error.localizedDescription
        }
        
        effectSubject.send(.showErrorMessage("연차 정보 저장에 실패했습니다"))
    }
    
    private func handleClearErrors() {
        state.remainingDaysError = nil
        state.generalError = nil
    }
    
    private func handleResetState() {
        state = VacationState()
    }
    
    private func validateRemainingDaysUI(_ days: Int) {
        if days < 0 {
            state.remainingDaysError = "연차는 0일 이상이어야 합니다"
        } else if days > 50 {
            state.remainingDaysError = "연차는 50일을 초과할 수 없습니다"
        } else {
            state.remainingDaysError = nil
        }
    }
    
    func initializeWith(profile: UserProfile) {
        send(.initializeWithProfile(profile))
    }
    
    func updateRemainingDays(_ days: Int) {
        send(.updateRemainingDays(days))
    }
    
    func updateHasHalfDay(_ hasHalf: Bool) {
        send(.updateHasHalfDay(hasHalf))
    }
    
    func saveVacationLeave() {
        send(.saveVacationLeave)
    }
    
    func clearErrors() {
        send(.clearErrors)
    }
    
    func resetState() {
        send(.resetState)
    }
}
