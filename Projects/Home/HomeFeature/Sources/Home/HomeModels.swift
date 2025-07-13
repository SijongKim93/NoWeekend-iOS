//
//  HomeModels.swift
//  HomeFeature
//
//  Created by 김나희 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Utils

// MARK: - Home State

struct HomeState: Equatable {
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var vacationBakingStatus: VacationBakingStatus = .notStarted
    var remainingAnnualLeave: Int = 10
    
    var currentMonth: String = ""
    var currentWeekOfMonth: String = ""
    
    var locationPermissionStatus: LocationPermissionStatus = .notDetermined
    var hasLocationPermission: Bool = false
    var currentLocation: LocationInfo? = nil
    var savedLocation: LocationInfo? = nil
    
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
    case vacationBakingCompleted
    case vacationBakingProcessed
    case remainingAnnualLeaveLoaded(Int)
    case locationIconTapped
    case locationPermissionChanged(LocationPermissionStatus)
}

// MARK: - Home Effect

enum HomeEffect {
    case showError(String)
    case navigateToDetail(VacationCardType)
    case showLoading
    case hideLoading
    case requestLocationPermission
    case openAppSettings
    case showLocationPermissionDeniedAlert
    case showLocationSettingsAlert
}
