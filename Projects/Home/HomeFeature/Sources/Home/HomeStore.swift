//
//  HomeStore.swift
//  HomeFeature
//
//  Created by 김나희 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI
import DesignSystem
import CalendarDomain
import DIContainer
import Combine
import Foundation
import Utils
import HomeDomain
import DIContainer
import ProfileDomain

@MainActor
final class HomeStore: ObservableObject {
    @Dependency private var homeUseCase: HomeUseCaseProtocol
    @Dependency private var getUserProfileUseCase: GetUserProfileUseCaseProtocol
    
    @Published private(set) var state = HomeState()
    @Published var weeklySchedules: [DailySchedule] = []
    @Dependency private var calendarUseCase: CalendarUseCaseProtocol
        
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
        case .loadSandwichHoliday:
            handleLoadSandwichHoliday()
        case .loadHolidays:
            handleLoadHolidays()
        case .selectedDateChanged(let date):
            handleSelectedDateChanged(date)
        }
    }
    
    private func handleViewDidLoad() {
        // 초기 데이터 로딩 로직
        // TODO: UseCase를 통해 사용자 정보 로딩
        updateCurrentDateInfo()
        setupLocationManager()
        
        // 샌드위치 휴일 및 공휴일 데이터 로딩
        send(.loadSandwichHoliday)
        send(.loadHolidays)
        
        // 생일 데이터 로딩
        Task {
            await loadUserBirthdayAsync()
        }
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
                await loadWeatherRecommendationsAsync()
            }
            
            await loadSandwichHolidayAsync()
            await loadHolidaysAsync()
            await loadUserBirthdayAsync()
            
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
            // 권한이 거부되면 디폴트 위치로 등록
            if !state.isLocationRegistered {
                send(.registerLocation)
            }
        }
    }
    
    private func handleRegisterLocation() {
        // 현재 위치가 있으면 사용, 없으면 디폴트 위치 사용
        let locationToRegister: LocationInfo
        if let currentLocation = state.currentLocation {
            locationToRegister = currentLocation
        } else {
            locationToRegister = locationManager.getDefaultLocation()
        }
        
        Task {
            do {
                try await homeUseCase.registerLocation(
                    latitude: locationToRegister.coordinate.latitude,
                    longitude: locationToRegister.coordinate.longitude
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
        // 위치가 등록되어 있으면 날씨 데이터 요청
        if state.isLocationRegistered {
            loadWeatherData()
        } else {
            // 위치가 등록되어 있지 않으면 디폴트 위치로 등록 후 날씨 데이터 요청
            send(.registerLocation)
        }
    }
    
    private func loadWeatherData() {
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
    
    private func handleLoadSandwichHoliday() {
        state.isHolidayLoading = true
        Task {
            do {
                let sandwichHolidays = try await homeUseCase.getSandwichHoliday()
                state.sandwichHoliday = sandwichHolidays
                state.isHolidayLoading = false
            } catch {
                state.isHolidayLoading = false
                effect.send(.showError("샌드위치 휴일 데이터를 가져오는데 실패했습니다."))
            }
        }
    }
    
    private func handleLoadHolidays() {
        state.isHolidayLoading = true
        Task {
            do {
                let holidays = try await homeUseCase.getHolidays()
                state.holidays = holidays
                state.isHolidayLoading = false
                updateShortCardsWithHolidayData()
            } catch {
                state.isHolidayLoading = false
                effect.send(.showError("공휴일 데이터를 가져오는데 실패했습니다."))
            }
        }
    }
    
    // MARK: - Async Loading Methods for Pull-to-Refresh
    
    private func loadWeatherRecommendationsAsync() async {
        // 위치가 등록되어 있으면 날씨 데이터 요청
        if state.isLocationRegistered {
            await loadWeatherDataAsync()
        } else {
            // 위치가 등록되어 있지 않으면 디폴트 위치로 등록 후 날씨 데이터 요청
            send(.registerLocation)
        }
    }
    
    private func loadWeatherDataAsync() async {
        state.isWeatherLoading = true
        do {
            let weatherData = try await homeUseCase.getWeatherRecommendations()
            state.weatherRecommendations = weatherData
            state.isWeatherLoading = false
        } catch {
            state.isWeatherLoading = false
            effect.send(.showError("날씨 데이터를 가져오는데 실패했습니다."))
        }
    }
    
    private func loadSandwichHolidayAsync() async {
        state.isHolidayLoading = true
        do {
            let sandwichHolidays = try await homeUseCase.getSandwichHoliday()
            state.sandwichHoliday = sandwichHolidays
            state.isHolidayLoading = false
        } catch {
            state.isHolidayLoading = false
            effect.send(.showError("샌드위치 휴일 데이터를 가져오는데 실패했습니다."))
        }
    }
    
    private func loadHolidaysAsync() async {
        state.isHolidayLoading = true
        do {
            let holidays = try await homeUseCase.getHolidays()
            state.holidays = holidays
            state.isHolidayLoading = false
            // 공휴일 데이터 로드 후 카드 업데이트
            updateShortCardsWithHolidayData()
        } catch {
            state.isHolidayLoading = false
            effect.send(.showError("공휴일 데이터를 가져오는데 실패했습니다."))
        }
    }
    
    private func handleSelectedDateChanged(_ date: Date) {
        // 선택된 날짜에 따라 카드 데이터 업데이트
        updateCardData(for: date)
    }
    
    private func updateCardData(for date: Date) {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        // 월 이름 가져오기
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let monthName = dateFormatter.monthSymbols[month - 1]
        
        // 선택된 월의 데이터로 카드 업데이트
        state.shortCards = [
            VacationCardItem(dateString: "\(month)/00(\(monthName)) ~ \(month)/00(\(monthName))", type: .sandwich),
            VacationCardItem(dateString: "\(month)/00(\(monthName))", type: .birthday),
            VacationCardItem(dateString: "\(month)/00(\(monthName))", type: .holiday),
            VacationCardItem(dateString: "\(month)/00(\(monthName))", type: .friday)
        ]
        
        updateShortCardsWithHolidayData()
        
        // TODO: 실제 API 호출로 해당 월의 데이터 가져오기
        // send(.loadSandwichHoliday)
        // send(.loadHolidays)
    }
    
    // MARK: - 공휴일 카드 업데이트 메서드
    private func updateShortCardsWithHolidayData() {
        guard !state.holidays.isEmpty else { return }
        
        let nextHoliday = getNextUpcomingHoliday()
        let holidayDateString = nextHoliday?.dateString ?? "공휴일 없음"
        
        for index in state.shortCards.indices {
            if state.shortCards[index].type == .holiday {
                state.shortCards[index] = VacationCardItem(
                    dateString: holidayDateString,
                    type: .holiday
                )
                break
            }
        }
    }
    
    // MARK: - 다음 공휴일 찾기 메서드
    private func getNextUpcomingHoliday() -> Holiday? {
        let today = Date()
        let calendar = Calendar.current
        
        let upcomingHolidays = state.holidays
            .filter { holiday in
                calendar.compare(holiday.date, to: today, toGranularity: .day) != .orderedAscending
            }
            .sorted { $0.date < $1.date }
        
        return upcomingHolidays.first
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
        } else {
            // 저장된 위치가 없으면 디폴트 위치로 등록
            send(.registerLocation)
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

// MARK: - 생일 관련 기능 (Extension)
extension HomeStore {
    
    private func loadUserBirthdayAsync() async {
        state.isBirthdayLoading = true
        do {
            let userProfile = try await getUserProfileUseCase.execute()
            state.userBirthday = userProfile.birthDate
            state.isBirthdayLoading = false
            
            updateBirthdayCard()
        } catch {
            state.isBirthdayLoading = false
            effect.send(.showError("생일 정보를 가져오는데 실패했습니다."))
        }
    }
    
    private func updateBirthdayCard() {
        guard let birthday = state.userBirthday, !birthday.isEmpty else {
            updateBirthdayCardWithDefault()
            return
        }
        
        if let nextBirthday = calculateNextBirthday(from: birthday) {
            let birthdayDateString = formatBirthdayDate(nextBirthday)
            state.nextBirthday = nextBirthday
            
            for index in state.shortCards.indices {
                if state.shortCards[index].type == .birthday {
                    state.shortCards[index] = VacationCardItem(
                        dateString: birthdayDateString,
                        type: .birthday
                    )
                    break
                }
            }
        } else {
            updateBirthdayCardWithDefault()
        }
    }
    
    private func updateBirthdayCardWithDefault() {
        for index in state.shortCards.indices {
            if state.shortCards[index].type == .birthday {
                state.shortCards[index] = VacationCardItem(
                    dateString: "생일 정보 없음",
                    type: .birthday
                )
                break
            }
        }
    }
    
    private func calculateNextBirthday(from birthDateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        
        if birthDateString.contains("-") {
            dateFormatter.dateFormat = "yyyy-MM-dd"
        } else {
            dateFormatter.dateFormat = "yyyyMMdd"
        }
        
        guard let birthDate = dateFormatter.date(from: birthDateString) else {
            print("❌ 생년월일 파싱 실패: \(birthDateString)")
            return nil
        }
        
        let calendar = Calendar.current
        let koreaTimeZone = TimeZone(identifier: "Asia/Seoul") ?? TimeZone.current
        var calendarWithTimezone = calendar
        calendarWithTimezone.timeZone = koreaTimeZone
        
        let today = Date()
        let currentYear = calendarWithTimezone.component(.year, from: today)
        let birthMonth = calendarWithTimezone.component(.month, from: birthDate)
        let birthDay = calendarWithTimezone.component(.day, from: birthDate)
        
        var thisYearBirthday = DateComponents()
        thisYearBirthday.year = currentYear
        thisYearBirthday.month = birthMonth
        thisYearBirthday.day = birthDay
        thisYearBirthday.timeZone = koreaTimeZone
        
        guard let thisYearBirthdayDate = calendarWithTimezone.date(from: thisYearBirthday) else {
            return nil
        }
        
        let comparison = calendarWithTimezone.compare(thisYearBirthdayDate, to: today, toGranularity: .day)
        
        if comparison == .orderedAscending {
            var nextYearBirthday = DateComponents()
            nextYearBirthday.year = currentYear + 1
            nextYearBirthday.month = birthMonth
            nextYearBirthday.day = birthDay
            nextYearBirthday.timeZone = koreaTimeZone
            
            return calendarWithTimezone.date(from: nextYearBirthday)
        } else {
            return thisYearBirthdayDate
        }
    }
    
    private func formatBirthdayDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "M/dd(E)"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        return dateFormatter.string(from: date)
    }
}

extension HomeStore {
    func loadWeeklySchedules() async {
        do {
            let schedules = try await calendarUseCase.getWeeklySchedules(for: Date())
            await MainActor.run {
                self.weeklySchedules = schedules
            }
        } catch {
            print("❌ 주간 스케줄 로드 실패: \(error)")
            await MainActor.run {
                self.weeklySchedules = []
            }
        }
    }
    
    func getSchedulesForDate(_ date: Date) -> [Schedule] {
        let dateString = date.toString(format: "yyyy-MM-dd")
        
        if let daySchedule = weeklySchedules.first(where: { $0.date == dateString }) {
            return daySchedule.schedules
        }
        
        return []
    }
    
    func calendarCellContent(for date: Date) -> some View {
        let schedules = getSchedulesForDate(date)
        return AnyView(temperatureImage(for: schedules).resizable().scaledToFit())
    }
    
    private func temperatureImage(for schedules: [Schedule]) -> Image {
        if schedules.isEmpty {
            return DS.Images.imgFlour
        }
        
        let hasVacation = schedules.contains { $0.category == .leave }
        if hasVacation {
            return DS.Images.imgToastVacation
        }
        
        let hasCompletedTasks = schedules.contains { $0.completed }
        
        if !hasCompletedTasks {
            return DS.Images.imgToastNone
        }
        
        let avgTemperature = calculateAverageTemperature(for: schedules)
        
        switch avgTemperature {
        case 0...25:
            return DS.Images.imgToastDefault
        case 26...50:
            return DS.Images.imgToastEven
        case 51...100:
            return DS.Images.imgToastBurn
        default:
            return DS.Images.imgToastDefault
        }
    }
    
    private func calculateAverageTemperature(for schedules: [Schedule]) -> Int {
        guard !schedules.isEmpty else { return 0 }
        
        let totalTemperature = schedules.reduce(0) { $0 + $1.temperature }
        return totalTemperature / schedules.count
    }
}
