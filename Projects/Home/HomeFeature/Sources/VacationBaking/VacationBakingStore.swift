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
            
        case .vacationDaysChanged(let days):
            handleVacationDaysChanged(days)
            
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
    
    private func handleVacationDaysChanged(_ days: Int) {
        state.vacationDays = days
        updateNextButtonState()
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
