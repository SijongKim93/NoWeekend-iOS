//
//  HomeView.swift
//  HomeFeature
//
//  Created by 김나희 on 7/9/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI
import DesignSystem
import Utils

public struct HomeView: View {
    @StateObject private var store = HomeStore()
    @EnvironmentObject private var coordinator: HomeCoordinator
    
    @State private var currentLongCardPage: Int = 0
    @State private var currentShortCardPage: Int = 0
    @State private var selectedDate: Date = Date()
    
    // 위치권한 관련 알림 상태
    @State private var showLocationPermissionDeniedAlert = false
    @State private var showLocationSettingsAlert = false
    @State private var showDatePickerBottomSheet = false
    
    // 바텀시트 상태 추가
    @State private var showTextInputBottomSheet = false
    @State private var inputText = ""
    
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
                        if !store.state.holidays.isEmpty {
                            HolidayCardSection(
                                holidays: store.state.holidays,
                                onAddTapped: { holiday in
                                    showTextInputBottomSheet = true
                                }
                            )
                            .background(DS.Colors.Background.alternative01)
                        }
                        
                        Spacer(minLength: 48)
                        WeekVacation(
                            currentMonth: store.state.currentMonth,
                            currentWeekOfMonth: store.state.currentWeekOfMonth,
                            weatherData: store.state.weatherRecommendations,
                            isWeatherLoading: store.state.isWeatherLoading,
                            onLocationIconTapped: {
                                store.send(.locationIconTapped)
                            },
                            onWeatherRefresh: {
                                store.send(.loadWeatherRecommendations)
                            },
                            store: store
                        )
                        
                        Spacer(minLength: 48)
                        ShortCardSection(
                            currentPage: $currentShortCardPage,
                            selectedDate: $selectedDate,
                            cards: store.state.shortCards,
                            onCardTapped: { cardType in
                                store.send(.vacationCardTapped(cardType))
                            },
                            onDateButtonTapped: {
                                showDatePickerBottomSheet = true
                            },
                            onAddTapped: { cardType in
                                showTextInputBottomSheet = true
                            }
                        )
                        Spacer()
                    }
                    .background(DS.Colors.Background.normal)
                }
            }
            .refreshable {
                await refreshData()
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
        .onChange(of: selectedDate) { oldValue, newValue in
            store.send(.selectedDateChanged(newValue))
        }
        .onReceive(store.effect) { effect in
            handleEffect(effect)
        }
        .alert("", isPresented: $showLocationPermissionDeniedAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("위치정보를 설정하지 않아 임의 위치로 검색됩니다.")
        }
        .alert("GPS 권한 설정", isPresented: $showLocationSettingsAlert) {
            Button("취소", role: .cancel) { }
            Button("확인") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
        } message: {
            Text("GPS 권한이 없습니다. 날씨 기반 휴가 추천을 하려면 GPS 권한이 필요합니다. 설정으로 이동하시겠습니까?")
        }
        .sheet(isPresented: $showDatePickerBottomSheet) {
            DatePickerWithLabelBottomSheet(selectedDate: $selectedDate)
        }
        .sheet(isPresented: $showTextInputBottomSheet) {
            TextInputBottomSheet(
                subtitle: "연차 제목을 작성하면\n할 일에 추가돼요",
                placeholder: "휴가 제목을 입력하세요",
                text: $inputText,
                isPresented: $showTextInputBottomSheet,
                onAddButtonTapped: {
                    print("할 일 추가됨: \(inputText)")
                    // TODO: 실제 할 일 추가 로직 구현
                    showTextInputBottomSheet = false
                    inputText = ""
                }
            )
        }
    }
    
    private func handleEffect(_ effect: HomeEffect) {
        switch effect {
        case .requestLocationPermission:
            LocationManager.shared.requestLocationPermission()
        case .openAppSettings:
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        case .showLocationPermissionDeniedAlert:
            showLocationPermissionDeniedAlert = true
        case .showLocationSettingsAlert:
            showLocationSettingsAlert = true
        case .showError(let message):
            print("Error: \(message)")
        case .navigateToDetail(let cardType):
            showTextInputBottomSheet = true
        case .showLoading:
            break
        case .hideLoading:
            break
        }
    }
    
    @MainActor
    private func refreshData() async {
        store.send(.refreshData)
    }
}

#Preview {
    HomeView()
}
