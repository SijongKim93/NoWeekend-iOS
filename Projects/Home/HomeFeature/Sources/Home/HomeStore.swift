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
import Utils

@MainActor
final class HomeStore: ObservableObject {
    @Published private(set) var state = HomeState()
    @Published var weeklySchedules: [DailySchedule] = []
    @Dependency private var calendarUseCase: CalendarUseCaseProtocol
        
    let effect = PassthroughSubject<HomeEffect, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
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
        }
    }
    
    private func handleViewDidLoad() {
        // 초기 데이터 로딩 로직
        // TODO: UseCase를 통해 사용자 정보 로딩
    }
    
    private func handleVacationCardTapped(_ cardType: VacationCardType) {
        effect.send(.navigateToDetail(cardType))
    }
    
    private func handleRefreshData() {
        state.isLoading = true
        effect.send(.showLoading)
        
        // 추후 UseCase 연결
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.state.isLoading = false
            self.effect.send(.hideLoading)
        }
    }
    
    private func handleVacationBakingCompleted() {
        state.vacationBakingStatus = .processing
        
        // 서버 API 호출 시뮬레이션
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.send(.vacationBakingProcessed)
        }
    }
    
    private func handleVacationBakingProcessed() {
        state.vacationBakingStatus = .completed
    }
    
    private func handleRemainingAnnualLeaveLoaded(_ days: Int) {
        state.remainingAnnualLeave = days
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
