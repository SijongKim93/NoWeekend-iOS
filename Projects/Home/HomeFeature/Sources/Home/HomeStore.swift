//
//  HomeStore.swift
//  HomeFeature
//
//  Created by 김나희 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Combine
import Foundation
import Utils
import HomeDomain
import DIContainer

@MainActor
final class HomeStore: ObservableObject {
    @Dependency private var homeUseCase: HomeUseCaseProtocol
    
    @Published private(set) var state = HomeState()
    let effect = PassthroughSubject<HomeEffect, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    private let locationManager = LocationManager.shared

    func send(_ intent: HomeIntent) {
        switch intent {
        case .viewDidLoad:
            handleViewDidLoad()
            
        case .vacationCardTapped(let cardType):
            handleVacationCardTapped(cardType)
            
        case .refreshData:
            handleRefreshData()
            
        case .vacationBakingCompleted:
            handleVacationBakingCompleted()
            
        case .vacationBakingProcessed:
            handleVacationBakingProcessed()
            
        case .remainingAnnualLeaveLoaded(let days):
            handleRemainingAnnualLeaveLoaded(days)
            
        case .locationIconTapped:
            handleLocationIconTapped()
            
        case .locationPermissionChanged(let status):
            handleLocationPermissionChanged(status)
            
        case .registerLocation:
            handleRegisterLocation()
            
        case .loadWeatherRecommendations:
            handleLoadWeatherRecommendations()
        }
    }
    
    private func handleViewDidLoad() {
        // 초기 데이터 로딩 로직
        // TODO: UseCase를 통해 사용자 정보 로딩
        updateCurrentDateInfo()
        setupLocationManager()
    }
    
    private func updateCurrentDateInfo() {
        // TimeZone 고정
        let koreaTimeZone = TimeZone(identifier: "Asia/Seoul") ?? TimeZone.current
        let now = Date()
        
        // 월 계산
        let monthFormatter = DateFormatter()
        monthFormatter.locale = Locale(identifier: "ko_KR")
        monthFormatter.dateFormat = "M"
        monthFormatter.timeZone = koreaTimeZone
        state.currentMonth = monthFormatter.string(from: now)
        
        // 주차 계산
        var calendar = Calendar.current
        calendar.timeZone = koreaTimeZone
        let weekOfMonth = calendar.component(.weekOfMonth, from: now)
        
        let weekNames = ["첫째", "둘째", "셋째", "넷째", "다섯째", "여섯째"]
        state.currentWeekOfMonth = weekNames[weekOfMonth - 1]
    }
    
    private func handleVacationCardTapped(_ cardType: VacationCardType) {
        effect.send(.navigateToDetail(cardType))
    }
    
    private func handleRefreshData() {
        state.isLoading = true
        effect.send(.showLoading)
        
        Task {
            // 저장된 위치가 있으면 날씨 데이터 새로고침
            if state.savedLocation != nil || state.isLocationRegistered {
                send(.loadWeatherRecommendations)
            }
            
            state.isLoading = false
            effect.send(.hideLoading)
        }
    }
    
    private func handleVacationBakingCompleted() {
        state.vacationBakingStatus = .processing
        
        // TODO: API 변경
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2초
            await MainActor.run {
                self.send(.vacationBakingProcessed)
            }
        }
    }
    
    private func handleVacationBakingProcessed() {
        state.vacationBakingStatus = .completed
    }
    
    private func handleRemainingAnnualLeaveLoaded(_ days: Int) {
        state.remainingAnnualLeave = days
    }
    
    private func handleLocationIconTapped() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // 위치 권한이 허용된 경우 - 새로운 위치 받기
            locationManager.refreshLocation()
            // 위치 변경 감지에서 자동으로 등록 처리됨
        case .denied, .restricted:
            // 위치 권한이 거부된 경우 - 설정 이동 팝업 표시
            effect.send(.showLocationSettingsAlert)
        case .notDetermined:
            // 위치 권한이 결정되지 않은 경우 - 권한 요청
            effect.send(.requestLocationPermission)
        default:
            break
        }
    }
    
    private func handleLocationPermissionChanged(_ status: LocationPermissionStatus) {
        let previousStatus = state.locationPermissionStatus
        state.locationPermissionStatus = status
        state.hasLocationPermission = (status == .authorizedWhenInUse || status == .authorizedAlways)
        
        // 권한이 거부된 경우 알림 표시 (이전 상태가 notDetermined일 때만)
        if (status == .denied || status == .restricted) && previousStatus == .notDetermined {
            effect.send(.showLocationPermissionDeniedAlert)
        }
    }
    
    private func handleRegisterLocation() {
        guard let location = state.currentLocation else { return }
        Task {
            do {
                try await homeUseCase.registerLocation(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
                state.isLocationRegistered = true
                // 위치 등록 성공 시 추천 데이터 요청
                send(.loadWeatherRecommendations)
            } catch {
                effect.send(.showError("위치 등록에 실패했습니다."))
            }
        }
    }

    private func handleLoadWeatherRecommendations() {
        // 저장된 위치가 있거나 위치가 등록되어 있으면 날씨 데이터 요청
        guard state.savedLocation != nil || state.isLocationRegistered else { return }
        
        state.isWeatherLoading = true
        Task {
            do {
                let weatherData = try await homeUseCase.getWeatherRecommendations()
                state.weatherRecommendations = weatherData
                state.isWeatherLoading = false
            } catch {
                state.isWeatherLoading = false
                effect.send(.showError("날씨 데이터를 가져오는데 실패했습니다."))
            }
        }
    }
    
    private func setupLocationManager() {
        // 위치 권한 상태 초기화
        state.locationPermissionStatus = locationManager.authorizationStatus
        state.hasLocationPermission = (locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways)
        
        // 저장된 위치 정보 불러오기
        state.savedLocation = locationManager.getSavedLocation()
        
        // 저장된 위치가 있으면 바로 날씨 데이터 요청
        if let savedLocation = state.savedLocation {
            state.currentLocation = savedLocation
            state.isLocationRegistered = true
            send(.loadWeatherRecommendations)
        }
        
        // 위치 권한 상태 변경 감지
        locationManager.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.send(.locationPermissionChanged(status))
            }
            .store(in: &cancellables)
        
        // 현재 위치 변경 감지
        locationManager.$currentLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                if let location = location {
                    self?.state.currentLocation = location
                    self?.state.savedLocation = location
                    // 위치가 저장되면 자동으로 위치 등록
                    self?.send(.registerLocation)
                }
            }
            .store(in: &cancellables)
        
        // 앱 시작 시 위치 권한 요청 (notDetermined 상태인 경우)
        if locationManager.authorizationStatus == .notDetermined {
            // 권한 요청
            effect.send(.requestLocationPermission)
        } else if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
            // 권한이 있지만 저장된 위치가 없으면 한 번만 받기
            if state.savedLocation == nil {
                locationManager.requestLocationOnce()
            }
        }
    }
} 
