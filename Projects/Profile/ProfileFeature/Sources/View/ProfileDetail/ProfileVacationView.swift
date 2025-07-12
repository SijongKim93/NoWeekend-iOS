//
//  ProfileVacationView.swift (수정됨)
//  ProfileFeature
//
//  Created by SiJongKim on 7/11/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI
import DIContainer
import DesignSystem
import Combine

struct ProfileVacationView: View {
    @EnvironmentObject private var coordinator: ProfileCoordinator
    @ObservedObject private var profileStore: ProfileStore
    @ObservedObject private var vacationStore: VacationStore
    
    @State private var cancellables = Set<AnyCancellable>()
    
    public init() {
        self.profileStore = DIContainer.shared.resolve(ProfileStore.self)
        self.vacationStore = DIContainer.shared.resolve(VacationStore.self)
    }
    
    public var body: some View {
        VStack {
            CustomNavigationBar(
                type: .backWithLabelAndSave("연차 관리"),
                onBackTapped: {
                    coordinator.pop()
                },
                onSaveTapped: {
                    vacationStore.saveVacationLeave()
                }
            )
            .padding(.bottom, 48)
            
            NWUserInputView(
                title: "올해 남은 연차를 알려주세요"
            ) {
                VStack {
                    NWRemainingDaysDisplaySection(
                        displayDays: displayDaysText,
                        displayHours: displayHoursText
                    )
                    
                    NWRemainingDaysInputSection(
                        remainingDays: Binding(
                            get: {
                                String(vacationStore.state.remainingDays)
                            },
                            set: { newValue in
                                if let intValue = Int(newValue) {
                                    vacationStore.updateRemainingDays(intValue)
                                } else if newValue.isEmpty {
                                    vacationStore.updateRemainingDays(0)
                                }
                            }
                        ),
                        remainingDaysError: vacationStore.state.remainingDaysError,
                        hasHalfDay: Binding(
                            get: { vacationStore.state.hasHalfDay },
                            set: { vacationStore.updateHasHalfDay($0) }
                        )
                    )
                    
                    Spacer()
                }
                .padding(.top, 40)
                .padding(.horizontal, 24)
            }
            
            Spacer()
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            setupEffectSubscription()
            loadVacationData()
        }
        .alert("오류", isPresented: .constant(vacationStore.state.generalError != nil)) {
            Button("확인") {
                vacationStore.clearErrors()
            }
        } message: {
            if let error = vacationStore.state.generalError {
                Text(error)
            }
        }
    }
    
    private var displayDaysText: String {
        let days = vacationStore.state.remainingDays
        return "\(days)"
    }

    private var displayHoursText: String {
        let hasHalf = vacationStore.state.hasHalfDay
        return hasHalf ? "4" : "0"
    }
    
    private var detailedDisplayDaysText: String {
        let days = vacationStore.state.remainingDays
        let hasHalf = vacationStore.state.hasHalfDay
        
        if hasHalf {
            return "\(days)일 반나절"
        } else {
            return "\(days)일"
        }
    }
    
    private var combinedDisplayText: String {
        let totalHours = vacationStore.state.totalRemainingHours
        let days = Int(totalHours / 8)
        let remainingHours = Int(totalHours.truncatingRemainder(dividingBy: 8))
        
        if remainingHours > 0 {
            return "\(days)일 \(remainingHours)시간"
        } else {
            return "\(days)일"
        }
    }
    
    private var decimalDisplayText: String {
        let totalDays = vacationStore.state.totalRemainingHours / 8
        return String(format: "%.1f", totalDays)
    }
    
    private func loadVacationData() {
        if let profile = profileStore.state.userProfile {
            vacationStore.initializeWith(profile: profile)
        } else {
            profileStore.loadInitialData()
        }
    }
    
    private func setupEffectSubscription() {
        profileStore.$state
            .map(\.userProfile)
            .compactMap { $0 }
            .removeDuplicates()
            .sink { profile in
                vacationStore.initializeWith(profile: profile)
            }
            .store(in: &cancellables)
        
        vacationStore.effect
            .receive(on: DispatchQueue.main)
            .sink { effect in
                handleVacationEffect(effect)
            }
            .store(in: &cancellables)
        
        profileStore.effect
            .receive(on: DispatchQueue.main)
            .sink { effect in
                switch effect {
                case .showErrorMessage(let message):
                    print("❌ Profile Load Error: \(message)")
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleVacationEffect(_ effect: VacationEffect) {
        switch effect {
        case .showSuccessMessage(let message):
            print("✅ Success: \(message)")
            
        case .showErrorMessage(let message):
            print("❌ Error: \(message)")
            
        case .navigateBack:
            coordinator.pop()
        }
    }
}
