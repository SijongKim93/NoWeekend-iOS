//
//  HomeModels.swift
//  HomeFeature
//
//  Created by 김나희 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

// MARK: - Home State

struct HomeState: Equatable {
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    var longCards: [VacationCardItem] = [
        VacationCardItem(dateString: "0/00(월) ~ 0/00(월)", type: .trip),
        VacationCardItem(dateString: "0/00(월) ~ 0/00(월)", type: .home)
    ]
    
    var shortCards: [VacationCardItem] = [
        VacationCardItem(dateString: "0/00(월) ~ 0/00(월)", type: .sandwich),
        VacationCardItem(dateString: "0/00(월)", type: .birthday),
        VacationCardItem(dateString: "0/00(월)", type: .holiday),
        VacationCardItem(dateString: "0/00(월)", type: .friday)
    ]
}

// MARK: - Home Intent

enum HomeIntent {
    case viewDidLoad
    case vacationCardTapped(VacationCardType)
    case refreshData
}

// MARK: - Home Effect

enum HomeEffect {
    case showError(String)
    case navigateToDetail(VacationCardType)
    case showLoading
    case hideLoading
}
