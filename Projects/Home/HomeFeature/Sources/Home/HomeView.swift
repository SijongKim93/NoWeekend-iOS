//
//  HomeView.swift
//  HomeFeature
//
//  Created by 김나희 on 7/9/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI
import DesignSystem

public struct HomeView: View {
    @StateObject private var store = HomeStore()
    @EnvironmentObject private var coordinator: HomeCoordinator
    
    @State private var currentLongCardPage: Int = 0
    @State private var currentShortCardPage: Int = 0
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .top) {
            DS.Images.imgGradient
                .resizable()
                .frame(height: 260)
                .ignoresSafeArea(edges: .top)
                .zIndex(0)

            ScrollView {
                VStack(spacing: 0) {
                    MainTopView(
                        vacationBakingStatus: store.state.vacationBakingStatus,
                        onVacationBakingTapped: {
                            switch store.state.vacationBakingStatus {
                            case .notStarted:
                                coordinator.push(.bakingVacation)
                            case .completed:
                                coordinator.push(.recommendVaction)
                            case .processing:
                                break
                            }
                        }
                    )
                    .zIndex(1)
                    
                    VStack {
                        Spacer(minLength: 48)
                        LongCardSection(
                            currentPage: $currentLongCardPage,
                            cards: store.state.longCards,
                            onCardTapped: { cardType in
                                store.send(.vacationCardTapped(cardType))
                            }
                        )
                        .background(DS.Colors.Background.alternative01)
                        
                        Spacer(minLength: 48)
                        WeekVacation()
                        
                        Spacer(minLength: 48)
                        ShortCardSection(
                            currentPage: $currentShortCardPage,
                            cards: store.state.shortCards,
                            onCardTapped: { cardType in
                                store.send(.vacationCardTapped(cardType))
                            }
                        )
                        Spacer()
                    }
                    .background(DS.Colors.Background.normal)
                }
            }
        }
        .onAppear {
            store.send(.viewDidLoad)
            coordinator.onVacationBakingCompleted = {
                store.send(.vacationBakingCompleted)
            }
        }
        .onChange(of: store.state.remainingAnnualLeave) { oldValue, newValue in
            coordinator.remainingAnnualLeave = newValue
        }
    }
}

#Preview {
    HomeView()
}
