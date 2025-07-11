//
//  HomeStore.swift
//  HomeFeature
//
//  Created by 김나희 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Combine
import Foundation

@MainActor
final class HomeStore: ObservableObject {
    @Published private(set) var state = HomeState()
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
        }
    }
    
    private func handleViewDidLoad() {
        // 초기 데이터 로딩 로직
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
} 
