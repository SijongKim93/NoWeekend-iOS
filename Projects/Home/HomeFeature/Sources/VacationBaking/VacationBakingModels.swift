//
//  VacationBakingModels.swift
//  HomeFeature
//
//  Created by 김나희 on 7/9/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

// MARK: - VacationBaking State

struct VacationBakingState: Equatable {
    var currentStep: VacationBakingStep = .vacationDaysInput
    var vacationDays: Int = 0
    var selectedVacationTypes: Set<VacationType> = []
    var isNextButtonEnabled: Bool = false
    var isCompleted: Bool = false
}

// MARK: - VacationBaking Intent

enum VacationBakingIntent {
    case viewDidLoad
    case vacationDaysChanged(Int)
    case vacationTypeToggled(VacationType)
    case nextButtonTapped
    case backButtonTapped
    case completeButtonTapped
}

// MARK: - VacationBaking Effect

enum VacationBakingEffect {
    case navigateToHome
    case showError(String)
}

// MARK: - VacationBaking Models

enum VacationBakingStep: CaseIterable {
    case vacationDaysInput
    case vacationTypeSelection
    
    var title: String {
        switch self {
        case .vacationDaysInput:
            return "휴가로 사용할\n연차 일수를 입력해주세요."
        case .vacationTypeSelection:
            return "딱 맞는 연차를 찾기 위해\n정보를 참고할게요"
        }
    }
    
    func subtitle(remainingDays: Int) -> String {
        switch self {
        case .vacationDaysInput:
            return "남은 연차 \(remainingDays)일"
        case .vacationTypeSelection:
            return "나의 표현하는 단어 선택"
        }
    }
}

enum VacationType: String, CaseIterable {
    case planning = "계획형"
    case activeVacation = "즉흥 자유형"
    case rest = "휴식"
    case selfImprovement = "자기계발"
    case housework = "야외 활동"
    case eating = "집콕"
    case meal = "음식"
    case watching = "관광"
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - VacationBaking Status

enum VacationBakingStatus: Equatable {
    case notStarted
    case processing
    case completed
    
    var titleText: String {
        switch self {
        case .notStarted:
            "온도를 식히는 휴식 어떠세요?"
        case .processing:
            "최대 2분 이내 확인할 수 있어요"
        case .completed:
            "토스트가 노릇하게 구워졌어요"
        }
    }
    
    var buttonText: String {
        switch self {
        case .notStarted:
            return "최대 7일 휴가 굽기"
        case .processing:
            return "휴가 굽는중"
        case .completed:
            return "휴가 쓸래말래?"
        }
    }
    
    var isButtonEnabled: Bool {
        switch self {
        case .notStarted, .completed:
            return true
        case .processing:
            return false
        }
    }
}
