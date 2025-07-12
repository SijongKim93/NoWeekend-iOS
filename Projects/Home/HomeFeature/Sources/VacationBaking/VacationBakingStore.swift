//
//  VacationBakingStore.swift
//  HomeFeature
//
//  Created by 김나희 on 7/9/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Combine
import Foundation

@MainActor
final class VacationBakingStore: ObservableObject {
    @Published private(set) var state = VacationBakingState()
    let effect = PassthroughSubject<VacationBakingEffect, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    func send(_ intent: VacationBakingIntent) {
        switch intent {
        case .viewDidLoad:
            handleViewDidLoad()
            
        case .vacationDaysInputChanged(let inputText):
            handleVacationDaysInputChanged(inputText)
            
        case .vacationTypeToggled(let type):
            handleVacationTypeToggled(type)
            
        case .nextButtonTapped:
            handleNextButtonTapped()
            
        case .backButtonTapped:
            handleBackButtonTapped()
            
        case .completeButtonTapped:
            handleCompleteButtonTapped()
        }
    }
    
    private func handleViewDidLoad() {
        state.currentStep = .vacationDaysInput
        updateNextButtonState()
    }
    
    private func handleVacationDaysInputChanged(_ inputText: String) {
        let (days, errorMessage) = validateVacationDaysInput(inputText)
        state.vacationDays = days
        state.errorMessage = errorMessage
        updateNextButtonState()
    }
    
    private func validateVacationDaysInput(_ inputText: String) -> (days: Int, errorMessage: String?) {
        let filtered = inputText.filter { $0.isNumber }
        
        // 숫자가 아닌 문자가 포함된 경우
        if !inputText.isEmpty && filtered.isEmpty {
            return (0, "숫자만 입력해주세요")
        }
        
        // 숫자 변환 및 유효성 검사
        guard let day = Int(filtered) else {
            return (0, nil)
        }
        
        // 범위 검사
        switch day {
        case 0:
            return (0, "1일부터 기입해주세요.")
        case 1...15:
            return (day, nil)
        default:
            return (day, "최대 15일 이내까지 추천받을 수 있어요.")
        }
    }
    
    private func handleVacationTypeToggled(_ type: VacationType) {
        if state.selectedVacationTypes.contains(type) {
            state.selectedVacationTypes.remove(type)
        } else {
            state.selectedVacationTypes.insert(type)
        }
        updateNextButtonState()
    }
    
    private func handleNextButtonTapped() {
        switch state.currentStep {
        case .vacationDaysInput:
            state.currentStep = .vacationTypeSelection
            updateNextButtonState()
            
        case .vacationTypeSelection:
            // 이미 완료 상태이므로 홈으로 이동
            effect.send(.navigateToHome)
        }
    }
    
    private func handleBackButtonTapped() {
        switch state.currentStep {
        case .vacationDaysInput:
            effect.send(.navigateToHome)
            
        case .vacationTypeSelection:
            state.currentStep = .vacationDaysInput
            updateNextButtonState()
        }
    }
    
    private func handleCompleteButtonTapped() {
        state.isCompleted = true
        effect.send(.navigateToHome)
    }
    
    private func updateNextButtonState() {
        switch state.currentStep {
        case .vacationDaysInput:
            state.isNextButtonEnabled = 0 < state.vacationDays && state.vacationDays < 16
            
        case .vacationTypeSelection:
            state.isNextButtonEnabled = state.selectedVacationTypes.count == 4
        }
    }
} 
