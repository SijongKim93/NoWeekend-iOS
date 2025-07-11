//
//  VacationBakingView.swift
//  HomeFeature
//
//  Created by 김나희 on 7/9/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI
import DesignSystem

struct VacationBakingView: View {
    @StateObject private var store = VacationBakingStore()
    @Environment(\.dismiss) private var dismiss
    
    let remainingAnnualLeave: Int
    let onCompleted: (() -> Void)?
    
    init(remainingAnnualLeave: Int = 10, onCompleted: (() -> Void)? = nil) {
        self.remainingAnnualLeave = remainingAnnualLeave
        self.onCompleted = onCompleted
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                type: .backOnly,
                onBackTapped: {
                    store.send(.backButtonTapped)
                }
            )
            
            VStack(spacing: 0) {
                // 타이틀 영역
                VacationBakingTitleView(
                    title: store.state.currentStep.title,
                    subtitle: store.state.currentStep.subtitle(remainingDays: remainingAnnualLeave)
                )
                .padding(.top, 32)
                .padding(.bottom, 48)
                
                // 단계별 콘텐츠
                Group {
                    switch store.state.currentStep {
                    case .vacationDaysInput:
                        VacationDaysInputView(
                            vacationDays: store.state.vacationDays,
                            remainingAnnualLeave: remainingAnnualLeave,
                            onDaysChanged: { days in
                                store.send(.vacationDaysChanged(days))
                            }
                        )
                        
                    case .vacationTypeSelection:
                        VacationTypeSelectionView(
                            selectedTypes: store.state.selectedVacationTypes,
                            onTypeToggled: { type in
                                store.send(.vacationTypeToggled(type))
                            }
                        )
                        .padding(.horizontal, -24)
                    }
                }
                
                Spacer()
                
                // 하단 버튼
                NWButton.black(
                    store.state.currentStep == .vacationTypeSelection ? "휴가 바삭하게 굽기" : "다음",
                    size: .xl,
                    isEnabled: store.state.isNextButtonEnabled,
                    action: {
                        store.send(.nextButtonTapped)
                    }
                )
                .frame(maxWidth: .infinity)
                .padding(.bottom, 34)
            }
            .padding(.horizontal, 24)
        }
        .navigationBarHidden(true)
        .background(DS.Colors.Background.normal)
        .onAppear {
            store.send(.viewDidLoad)
        }
        .onReceive(store.effect) { effect in
            switch effect {
            case .navigateToHome:
                onCompleted?()
                dismiss()
            case .showError(let message):
                // 에러 처리
                print("Error: \(message)")
            }
        }
    }
}

#Preview {
    VacationBakingView()
} 
